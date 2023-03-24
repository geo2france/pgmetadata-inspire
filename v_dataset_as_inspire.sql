CREATE VIEW pgmetadata.v_dataset_as_inspire AS
WITH "MaintenanceFrequencyCode"(code, inspire_code) AS (
	VALUES
	('NEC','asNeeded'),
	('YEA','annually'),
	('MON','monthly'),
	('WEE', 'weekly'),
	('DAY','daily'),
	('TRI', 'quarterly'),
	('BIA', 'biannually'),
	('IRR','irregular'),
	('NOP','notPlanned')
),
"LinkProtocol" (code, inspire_code) AS (
	VALUES
	('download','WWW:DOWNLOAD-1.0-http--download'),
	('WFS','OGC:WFS'),
	('WMS','OGC:WMS'),
	('WMTS','OGC:MWTS'),
	('FTP', 'WWW:DOWNLOAD-1.0-ftp--download')
),
"Role" (code, inspire_code) AS (
	VALUES
	('CU', 'custodian'),
	('OW', 'owner'),
	('DI', 'distributor'),
	('OR', 'originator')
)
SELECT d.schema_name, d.table_name, d.uid, XMLELEMENT (NAME "gmd:MD_Metadata", 
XMLATTRIBUTES (
		'http://www.isotc211.org/2005/gmd http://www.isotc211.org/2005/gmd/gmd.xsd http://www.isotc211.org/2005/gmx http://www.isotc211.org/2005/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd' AS "xsi:schemaLocation",
		'http://www.isotc211.org/2005/gmd' AS "xmlns:gmd",
		'http://www.w3.org/2001/XMLSchema-instance' AS "xmlns:xsi",
		'http://www.isotc211.org/2005/gco' AS "xmlns:gco",
		'http://www.isotc211.org/2005/srv' AS "xmlns:srv",
		'http://www.isotc211.org/2005/gmx' AS "xmlns:gmx"), 
	XMLELEMENT(NAME "gmd:fileIdentifier",
		XMLELEMENT(NAME "gco:CharacterString", d.uid)
	),
	XMLELEMENT(NAME "gmd:characterSet",
		XMLELEMENT(NAME "gmd:MD_CharacterSetCode", XMLATTRIBUTES (REPLACE(lower(d.encodage),'-','') as "codeListValue", 'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_CharacterSetCode' AS "codeList"))
	),
	XMLELEMENT(NAME "gmd:hierarchyLevel",
		XMLELEMENT(NAME "gmd:MD_ScopeCode", XMLATTRIBUTES ('dataset' AS "codeListValue", 'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode' AS "codeList") )
	),
	XMLELEMENT(NAME "gmd:identificationInfo",
		XMLELEMENT(NAME "gmd:MD_DataIdentification",
			XMLELEMENT(NAME "gmd:citation", 
				XMLELEMENT(NAME "gmd:CI_Citation",
					XMLELEMENT(NAME "gmd:title",
						XMLELEMENT(NAME "gco:CharacterString", d.title)
					),
					XMLELEMENT(NAME "gmd:date",
						XMLELEMENT(NAME "gmd:CI_Date",
							XMLELEMENT(NAME "gmd:date",
								XMLELEMENT(NAME "gco:Date", d.publication_date::date)
							),
							XMLELEMENT(NAME "gmd:dateType",
								XMLELEMENT(NAME "gmd:CI_DateTypeCode", 
									XMLATTRIBUTES('publication'  AS "codeListValue", 'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode' AS "codeList" )
								)
							)
						)
					),
					XMLELEMENT(NAME "gmd:date",
						XMLELEMENT(NAME "gmd:CI_Date",
							XMLELEMENT(NAME "gmd:date",
								XMLELEMENT(NAME "gco:Date", d.creation_date::date)
							),
							XMLELEMENT(NAME "gmd:dateType",
								XMLELEMENT(NAME "gmd:CI_DateTypeCode", 
									XMLATTRIBUTES('creation'  AS "codeListValue", 'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode' AS "codeList" )
								)
							)
						)
					)
				)
			),
			XMLELEMENT(NAME "gmd:abstract",
				XMLELEMENT(NAME "gco:CharacterString", d.abstract)
			),
			XMLELEMENT(NAME "gmd:status",
				XMLELEMENT(NAME "gmd:MD_ProgressCode", XMLATTRIBUTES (CASE 
																		WHEN d.publication_frequency = 'NOP' THEN 'completed'
																		ELSE 'onGoing' END AS "codeListValue" , 
																	'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ProgressCode' AS "codeList"))
			), --Parti-pris ?
			contacts.agg_ct,
			XMLELEMENT(NAME "gmd:descriptiveKeywords",
				XMLELEMENT(NAME "gmd:MD_Keywords",
					kw.agg_kw
				)
			),
			XMLELEMENT(NAME "gmd:resourceConstraints",
				XMLELEMENT(NAME "gmd:MD_LegalConstraints",
					XMLELEMENT(NAME "gmd:accessConstraints",
						XMLELEMENT(NAME "gmd:MD_RestrictionCode", XMLATTRIBUTES(
							CASE WHEN d.license IS NOT NULL THEN 'license'
								WHEN d.confidentiality = 'RES' THEN 'restricted' 
								WHEN d.confidentiality = 'OPE' THEN 'otherRestrictions' END AS "codeListValue", 
							'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_RestrictionCode' AS "codeList") )
					),
					XMLELEMENT(NAME "gmd:otherConstraints",
						XMLELEMENT(NAME "gco:CharacterString",license.label_en) 
					)
				)
			),
			XMLELEMENT (NAME "gmd:spatialResolution",
				XMLELEMENT (NAME "gmd:MD_Resolution",
					XMLELEMENT (NAME "gmd:equivalentScale",
						XMLELEMENT (NAME "gmd:MD_RepresentativeFraction",
							XMLELEMENT (NAME "gmd:denominator",
								XMLELEMENT (NAME "gco:Integer", d.minimum_optimal_scale)
							)
						)
					)
				)
			),			
			XMLELEMENT(NAME "gmd:resourceMaintenance",
				XMLELEMENT(NAME "gmd:MD_MaintenanceInformation",
					XMLELEMENT(NAME "gmd:maintenanceAndUpdateFrequency",
						XMLELEMENT(NAME "gmd:MD_MaintenanceFrequencyCode",
							XMLATTRIBUTES (COALESCE("MaintenanceFrequencyCode".inspire_code, 'unknown') AS "codeListValue", 'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_MaintenanceFrequencyCode' AS "codeList")
						)
					)
				)
			),
			XMLELEMENT (NAME "gmd:extent",
				XMLELEMENT (NAME "gmd:EX_Extent",
					XMLELEMENT (NAME "gmd:geographicElement",
						XMLELEMENT (NAME "gmd:EX_GeographicBoundingBox",
							XMLELEMENT (NAME "gmd:westBoundLongitude",
								XMLELEMENT (NAME "gco:Decimal", st_xmax(st_envelope(geom)))
							),
							XMLELEMENT (NAME "gmd:eastBoundLongitude",
								XMLELEMENT (NAME "gco:Decimal", st_xmin(st_envelope(geom)))
							),
							XMLELEMENT (NAME "gmd:southBoundLatitude",
								XMLELEMENT (NAME "gco:Decimal", st_ymin(st_envelope(geom)))
							),
							XMLELEMENT (NAME "gmd:northBoundLatitude",
								XMLELEMENT (NAME "gco:Decimal", st_ymax(st_envelope(geom)))
							)
						)
					)
				)
			)
		)
	),
	XMLELEMENT(NAME "gmd:distributionInfo",
		XMLELEMENT(NAME "gmd:MD_Distribution",
			XMLELEMENT(NAME "gmd:transferOptions",
				XMLELEMENT(NAME "gmd:MD_DigitalTransferOptions", --Liens de la fiches + liens du geoserveur g2f
					links.agg_lk, 
					XMLELEMENT(NAME "gmd:onLine", --WMS Geo2france
						XMLELEMENT(NAME "gmd:CI_OnlineResource",
							XMLELEMENT(NAME "gmd:linkage", 
								XMLELEMENT(NAME "gmd:URL",'https://www.geo2france.fr/geoserver/cen_hdf/ows')
							),
							XMLELEMENT(NAME "gmd:name",
								XMLELEMENT(NAME "gco:CharacterString", 'cen_hdf:'||d.table_name)
							),
							XMLELEMENT(NAME "gmd:protocol",
								XMLELEMENT(NAME "gco:CharacterString", 'OGC:WMS')
							),
							XMLELEMENT(NAME "gmd:description",
								XMLELEMENT(NAME "gco:CharacterString", d.abstract)
							)
						)
					),
					XMLELEMENT(NAME "gmd:onLine", --WFS Geo2france
						XMLELEMENT(NAME "gmd:CI_OnlineResource",
							XMLELEMENT(NAME "gmd:linkage", 
								XMLELEMENT(NAME "gmd:URL",'https://www.geo2france.fr/geoserver/cen_hdf/ows')
							),
							XMLELEMENT(NAME "gmd:name",
								XMLELEMENT(NAME "gco:CharacterString", 'cen_hdf:'||d.table_name)
							),
							XMLELEMENT(NAME "gmd:protocol",
								XMLELEMENT(NAME "gco:CharacterString", 'OGC:WFS')
							),
							XMLELEMENT(NAME "gmd:description",
								XMLELEMENT(NAME "gco:CharacterString", d.abstract)
							)
						)
					)
				)
			)
		)
	)
)
FROM pgmetadata.dataset d
LEFT JOIN LATERAL ( 
	SELECT XMLAGG( 
				XMLELEMENT(NAME "gmd:pointOfContact",
					XMLELEMENT(NAME "gmd:CI_ResponsibleParty",
						XMLELEMENT(NAME "gmd:organisationName",
							XMLELEMENT (NAME "gco:CharacterString", c2."name" )
						),
						XMLELEMENT(NAME "gmd:contactInfo",
							XMLELEMENT(NAME "gmd:address",
								XMLELEMENT(NAME "gmd:CI_Address",
									XMLELEMENT(NAME "gmd:electronicMailAddress",
										XMLELEMENT(NAME "gco:CharacterString", c2.email)
									)
								)
							)
						),
						XMLELEMENT(NAME "gmd:role",
							XMLELEMENT(NAME "gmd:CI_RoleCode",
								XMLATTRIBUTES('https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_RoleCode' AS "codeList", r.inspire_code AS "codeListValue")
							)
						)
					)
				)
			) AS agg_ct 
				FROM pgmetadata.contact c2 
				JOIN pgmetadata.dataset_contact dc2 ON dc2.fk_id_contact = c2.id 
				LEFT JOIN "Role" r ON r.code = dc2.contact_role 
				WHERE dc2.fk_id_dataset  = d.id)  contacts ON True
LEFT JOIN LATERAL (SELECT  XMLAGG(
						XMLELEMENT(NAME "gmd:keyword",
							XMLELEMENT(NAME "gco:CharacterString", "unnest" )
						)
					) AS agg_kw FROM UNNEST(string_to_array(d.keywords,',')) ) kw ON TRUE
LEFT JOIN LATERAL ( 
	SELECT XMLAGG(
					XMLELEMENT(NAME "gmd:onLine",
						XMLELEMENT(NAME "gmd:CI_OnlineResource",
							XMLELEMENT(NAME "gmd:linkage", 
								XMLELEMENT(NAME "gmd:URL",l.url)
							),
							XMLELEMENT(NAME "gmd:name",
								XMLELEMENT(NAME "gco:CharacterString", l."name")
							),
							XMLELEMENT(NAME "gmd:protocol",
								XMLELEMENT(NAME "gco:CharacterString", lp.inspire_code)
							),
							XMLELEMENT(NAME "gmd:description",
								XMLELEMENT(NAME "gco:CharacterString", l.description)
							),
							XMLELEMENT(NAME "gmd:function",
								XMLELEMENT(NAME "gmd:CI_OnLineFunctionCode", 
									XMLATTRIBUTES(CASE
													WHEN l."type" in ('information', 'search',' order') THEN l."type" 
													ELSE 'download'	END AS "codeListValue", 
												'http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_OnLineFunctionCode' AS "codeList")
								)
							)
						)
					)
) AS agg_lk FROM pgmetadata.link l JOIN pgmetadata.dataset_link dl ON dl.fk_id_link = l.id LEFT JOIN "LinkProtocol" lp ON lp.code = l."type"  WHERE dl.fk_id_dataset  = d.id) links ON True
LEFT JOIN "MaintenanceFrequencyCode" ON "MaintenanceFrequencyCode".code = d.publication_frequency 
LEFT JOIN pgmetadata.glossary license ON license.code=d.license AND "field"='dataset.license'

