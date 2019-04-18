<?xml version="1.1"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns="http://www.w3.org/1999/xhtml">
	
	<xsl:variable name="xubmit-base-url" select=" 'http://algernon.dlib.indiana.edu:8080/xubmit/rest/repository/newton/' "/>

	<xsl:template match="/c:directory">
		<html>
			<head>
				<title>Directory of texts</title>
				<style type="text/css">
					table {
					}
					td {
						padding-left: 1em;
						padding-right: 1em;
						padding-top: 0.5em;
						padding-bottom: 0.5em;
					}
					tr:nth-child(even) {
						background-color: #E0E0E0;
					}
				</style>
			</head>
			<body>
				<h1>Directory of texts</h1>
				<table>
					<xsl:for-each select="c:file">
						<xsl:sort select="@name"/>
						<xsl:variable name="name" select="substring-before(@name, '.xml')"/>
						<tr>
							<td><xsl:value-of select="@name"/></td>
							<td><a href="{$xubmit-base-url}{@name}">Download source P4 from Xubmit</a></td>
							<td><a href="{$name}/">View converted TEI P5</a></td>
							<td><a href="../text/{$name}/">View as simple HTML</a></td>
						</tr>
					</xsl:for-each>
				</table>
			</body>
		</html>
	</xsl:template>
	
		
</xsl:stylesheet>
