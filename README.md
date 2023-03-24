# pgmetadata-inspire 

Une vue SQL permettant, à partir de [PgMetadata](https://github.com/3liz/qgis-pgmetadata-plugin), de générer des fichiers XML au format [INSPIRE](https://inspire.ec.europa.eu/id/document/tg/metadata-iso19139), pour import dans GeoNetwork.
Cette vue a été créée pour permettre au [Conservatoire d'Espaces Naturels des Hauts-de-France](https://www.cen-hautsdefrance.org/) de publier rapidement des métadonnées sur la plateforme [Géo2France](https://www.geo2france.fr/).

Le depôt contient la vue et un bash permettant d'exporter l'ensemble des fichiers XML.

> **Warning**
> La vue ajoute 2 liens dans le xml. Ceux-ci correspondent aux flux WMS et WFS qui seront publiée sur le Geoserver par le CEN-HdF.
> A supprimer ou adapter pour utilisation dans un autre contexte.

