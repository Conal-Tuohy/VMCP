<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0">
	<!-- transform a TEI document into an HTML page-->
	
	<xsl:param name="view"/><!-- 'diplomatic' or 'normalized' or 'introduction' -->
	<xsl:key name="char-by-ref" match="char[@xml:id]" use="concat('#', @xml:id)"/>
	<xsl:variable name="title" select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem/title"/>
	
	<xsl:template match="/tei:TEI">
		<html>
			<head>
				<title><xsl:value-of select="$title"/></title>
				<link href="/css/tei.css" rel="stylesheet" type="text/css"/>
			</head>
			<body>
				<div class="tei">
					<div class="tei-view-selection">
						<xsl:call-template name="render-view-option">
							<xsl:with-param name="option-view" select=" 'normalized' "/>
							<xsl:with-param name="option-label" select=" 'Normalized Transcription' "/>
						</xsl:call-template>
						<xsl:call-template name="render-view-option">
							<xsl:with-param name="option-view" select=" 'diplomatic' "/>
							<xsl:with-param name="option-label" select=" 'Diplomatic Transcription' "/>
						</xsl:call-template>
						<xsl:call-template name="render-view-option">
							<xsl:with-param name="option-view" select=" 'introduction' "/>
							<xsl:with-param name="option-label" select=" 'Introduction' "/>
						</xsl:call-template>
					</div>
					<!-- TODO shouldn't heading be a string constructed from msIdentifer? -->
					<h1><xsl:value-of select="$title"/></h1>
					<xsl:apply-templates select="tei:teiHeader"/>
					<xsl:choose>
						<xsl:when test="$view = 'introduction'">
							<xsl:apply-templates select="$introduction"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="tei:text"/>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</body>
		</html>
	</xsl:template>
	
	<xsl:variable name="introduction" select="/TEI/teiHeader/fileDesc/sourceDesc/msDesc/msContents/msItem/note[@type='introduction']"/>
	
	<xsl:template name="render-view-option">
		<xsl:param name="option-view"/>
		<xsl:param name="option-label"/>
		<!-- render the option unless it's a link to an introduction and there is actually no introduction in the text -->
		<xsl:if test="not($option-view = 'introduction' and not($introduction))">
			<xsl:choose>
				<xsl:when test="$view = $option-view">
					<span><xsl:value-of select="$option-label"/></span>
				</xsl:when>
				<xsl:otherwise>
					<a href="{$option-view}"><xsl:value-of select="$option-label"/></a>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="teiHeader">
		<details class="tei-teiHeader">
			<summary>Manuscript Information</summary>
			<div class="expansion">
				<xsl:variable name="now" select="current-dateTime()"/>
				<xsl:apply-templates select="fileDesc/sourceDesc/msDesc/msContents/msItem/author" />
				<xsl:apply-templates select="fileDesc/sourceDesc/msDesc/msContents/msItem/title" />
				<xsl:apply-templates select="fileDesc/sourceDesc/msDesc/msContents/msItem/note[@type='description']" />
				<xsl:apply-templates select="fileDesc/sourceDesc/msDesc/physDesc/objectDesc/supportDesc" />
				<xsl:apply-templates select="profileDesc/langUsage"/>
				<xsl:apply-templates select="fileDesc/sourceDesc/msDesc/history" />
				<!-- identifiers -->
				<xsl:variable name="msIdentifier" select="fileDesc/sourceDesc/msDesc/msIdentifier"/>
				<div>
					<h2 class="inline">Physical Location:</h2>
					<xsl:value-of select="string-join(
						(
							$msIdentifier/collection, 
							$msIdentifier/idno, 
							$msIdentifier/repository, 
							$msIdentifier/institution, 
							string-join(
								(
									$msIdentifier/settlement, 
									$msIdentifier/region, 
									$msIdentifier/country
								),
								', '
							)
						),
						'&#160;'
					)"/>
				</div>
				<div>
					<h2 class="inline">Electronic Publication:</h2>
					<xsl:value-of select="concat(
						$msIdentifier/altIdentifier/idno[@type='collection'], 
						'&#160;', 
						$msIdentifier/idno, 
						'. '
					)"/>
					<xsl:for-each select="fileDesc/publicationStmt">
						<xsl:value-of select="concat('Published ', date, ', ', publisher, '&#160;', pubPlace, '.')"/>
					</xsl:for-each>
				</div>
				<xsl:apply-templates select="fileDesc/titleStmt/respStmt" />
				<div>
					<h2>Preferred Citation:</h2>
					<xsl:for-each select="fileDesc/sourceDesc/msDesc/msContents/msItem/author">
						<xsl:value-of select="concat(., '. ')"/>
					</xsl:for-each>
					<xsl:value-of select="
						concat(
							'&quot;',
							fileDesc/sourceDesc/msDesc/msIdentifier/altIdentifier/idno[@type='collection'],
							'&#160;',
							fileDesc/sourceDesc/msDesc/msIdentifier/idno,
							'&quot;.'
						)
					"/>
					<em>The Chymistry of Isaac Newton</em>
					<xsl:text>.  Ed. </xsl:text>
					<xsl:value-of select="titleStmt/respStmt/name[@type='editor']"/>
					<xsl:text>&#160;</xsl:text>
					<xsl:value-of select="fileDesc/publicationStmt/date"/>
					<xsl:text>. Retrieved </xsl:text>
					<xsl:value-of select="format-dateTime($now, '[MNn] [D], [Y]', 'en', (),() )"/>
					<xsl:text> from: http://purl.dlib.indiana.edu/iudl/newton/</xsl:text>
					<xsl:value-of select="//altIdentifier/idno[@type='iunp']"/>
				</div>
			</div>
		</details>
	</xsl:template>
	<xsl:template match="titleStmt/respStmt" mode="create-content">
		<xsl:if test="name/@type=('editor', 'reviewer', 'transcriber')">
			<h2 class="inline"><xsl:value-of select="resp"/>:</h2>
			<xsl:value-of select="name"/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="history" mode="create-content">
		<h2 class="inline">Custodial History:</h2>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="msItem/author" mode="create-content">
		<h2 class="inline">Author:</h2>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="msItem/title" mode="create-content">
		<xsl:if test="position()=1"><!-- only add "TItle:" before the first title -->
			<h2 class="inline">Title:</h2>
		</xsl:if>
		<xsl:apply-templates/>
	</xsl:template>	
	<xsl:template match="msItem/note[@type='description']" mode="create-content">
		<h2 class="inline">Contents:</h2>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="support" mode="create-content">
		<h2 class="inline">Physical Description:</h2>
		<xsl:apply-templates/>
	</xsl:template>	
	<xsl:template match="langUsage" mode="create-content">
		<h2 class="inline">Languages:</h2>
		<xsl:value-of select="string-join(language, ', ')"/>
	</xsl:template>
	
	<xsl:template match="langUsage/language">
		<xsl:value-of select="."/><xsl:if test="not(position()=last())">, </xsl:if>
	</xsl:template>
	
	<!-- https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ST.html#STBTC -->
	<!-- TEI "phrase-level", model.global.edit, and "gLike" elements are mapped to html:span -->
	<!-- Also tei:label since it is only used in the chymistry corpus with phrase content -->
	<xsl:template priority="-0.1" match="
		binaryObject | formula | graphic | media | code | distinct | emph | foreign | gloss | ident | mentioned | 
		soCalled | term | title | hi | caesura | rhyme | address | affiliation | email | date | time | depth | dim | 
		geo | height | measure | measureGrp | num | unit | width | name | orgName | persName | geogFeat |
		offset | addName | forename | genName | nameLink | roleName | surname | bloc | country | district | 
		geogName | placeName | region | settlement | climate | location | population | state | terrain | trait | 
		idno | lang | objectName | rs | abbr | am | choice | ex | expan | subst | add | corr | damage | del | 
		handShift | mod | orig | redo | reg | restore | retrace | secl | sic | supplied | surplus | unclear | undo | 
		catchwords | dimensions | heraldry | locus | locusGrp | material | objectType | origDate | origPlace | 
		secFol | signatures | stamp | watermark | att | gi | tag | val | ptr | ref | oRef | pRef | c | cl | m | pc | 
		phr | s | seg | w | specDesc | specList
		|
		addSpan | app | damageSpan | delSpan | gap | space | witDetail
		|
		g
		|
		label
	">
		<xsl:element name="span">
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:apply-templates mode="create-content" select="."/>
		</xsl:element>
	</xsl:template>
	
	<!-- non-phrase-level TEI elements are mapped to html:div -->
	<xsl:template match="*">
		<xsl:element name="div">
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:apply-templates mode="create-content" select="."/>
		</xsl:element>
	</xsl:template>
	
	<!-- populate an HTML element's set of attributes -->
	<xsl:template mode="create-attributes" match="*">
		<xsl:attribute name="class" select="
			string-join(
				(
					concat('tei-', local-name()),
					for $rend in tokenize(@rend) return concat('rend-', $rend),
					for $type in tokenize(@type) return concat('type-', $type),
					for $place in tokenize(@place) return concat('place-', $place)
				),
				' '
			)
		"/>
		<xsl:for-each select="@xml:lang"><xsl:attribute name="lang" select="."/></xsl:for-each>
		<xsl:for-each select="@xml:id"><xsl:attribute name="id" select="."/></xsl:for-each>
	</xsl:template>
	
	<!-- populate an HTML element's content -->
	<xsl:template mode="create-content" match="*">
		<!-- The content of an HTML element which represents a TEI element is normally produced by applying templates to the children of a TEI element. -->
		<!-- This can be over-ridden for specific TEI elements, e.g. <tei:space/> is an empty element, but it should produce an actual space character in the HTML -->
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="gap" mode="create-content">
		<xsl:text>illeg.</xsl:text>
	</xsl:template>
	<xsl:template match="gap" mode="create-attributes">
		<xsl:next-match/>
		<xsl:attribute name="title" select="
			string-join(
				(
					'illegible; reason:',
					@reason,
					@extent
				),
				' '
			)
		"/>
	</xsl:template>
	<xsl:template match="add">
		<xsl:element name="ins">
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:apply-templates mode="create-content" select="."/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="del">
		<xsl:element name="del">
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:apply-templates mode="create-content" select="."/>
		</xsl:element>
	</xsl:template>	
	<!-- elements rendered only in diplomatic view -->
	<xsl:template match="choice/orig" priority="1">
		<xsl:if test="$view = 'diplomatic' ">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="choice/abbr" priority="1">
		<xsl:if test="$view = 'diplomatic' ">
			<xsl:element name="abbr">
				<xsl:apply-templates/>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	
	<!-- elements rendered only in normalized view -->
	<xsl:template match="choice/reg" priority="1">
		<xsl:if test="$view = 'normalized' ">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	<xsl:template match="choice/expan" priority="1">
		<xsl:if test="$view = 'normalized' ">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	
	<!-- significant white space -->
	<xsl:template match="space[@dim='horizontal']" mode="create-attributes">
		<xsl:attribute name="style" select="concat('display: inline-block; width: ', @quantity div 2, 'em;')"/>
	</xsl:template>
	<xsl:template match="space[@dim='vertical']" mode="create-attributes">
		<xsl:attribute name="style" select="concat('display: block; height: ', @quantity, 'em;')"/>
	</xsl:template>
	<xsl:template match="space" mode="create-content">
		<xsl:text> </xsl:text>
	</xsl:template>
	<xsl:template match="lb">
		<xsl:element name="br"/>
	</xsl:template>
	
	<!-- render the name of a special character using a @title -->
	<xsl:template match="g[@ref]" mode="create-attributes">
		<xsl:attribute name="title" select="key('char-by-ref', @ref)/charName"/>
	</xsl:template>
	
	<!-- page breaks -->
	<xsl:key name="surface-by-id" match="surface[@xml:id]" use="@xml:id"/>
	<xsl:template match="milestone[@unit='folio'][@xml:id]">
		<xsl:element name="figure">
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:element name="figcaption"><xsl:value-of select="@n"/></xsl:element>
			<xsl:variable name="surface" select="key('surface-by-id', substring-after(@facs, '#'))"/>
			<a class="large-image" href="{$surface/graphic[@rend='large']/@url}">
				<img class="thumbnail" src="{$surface/graphic[@rend='thumbnail']/@url}"/>
			</a>
		</xsl:element>
	</xsl:template>
	
	<!-- lists and tables -->
	<xsl:template match="list" priority="1">
		<xsl:apply-templates select="tei:head"/><!-- HTML list headings must precede <ul> element -->
		<ul>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<!-- generate child <li> only for list/item, not e.g. list/milestone -->
			<xsl:apply-templates select="tei:item"/>
		</ul>
	</xsl:template>
	<xsl:template match="item" priority="1">
		<li>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:variable name="current-item" select="."/>
			<!-- include a rendition of the preceding non-<item>, non-<head> siblings as part of this <li> -->
			<xsl:apply-templates select="preceding-sibling::*[not(self::tei:item | self::tei:head)][following-sibling::tei:item[1] is $current-item]"/>
			<xsl:apply-templates mode="create-content" select="."/>
		</li>
	</xsl:template>
	<xsl:template match="table" priority="1">
		<table>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<!-- generate child <caption> and <tr> only for table, not e.g. table/milestone -->
			<xsl:apply-templates select="tei:head | tei:row"/>
		</table>
	</xsl:template>
	<xsl:template match="table/head" priority="1">
		<caption>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:apply-templates mode="create-content" select="."/>
		</caption>
	</xsl:template>
	<xsl:template match="row" priority="1">
		<tr>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:variable name="current-row" select="."/>
			<!-- include a rendition of the preceding non-<row> siblings as part of this <tr> -->
			<xsl:apply-templates select="preceding-sibling::*[not(self::tei:row)][following-sibling::tei:row[1] is $current-row]"/>
			<xsl:apply-templates mode="create-content" select="."/>
		</tr>
	</xsl:template>
	<xsl:template match="cell" priority="1">
		<td>
			<xsl:apply-templates mode="create-attributes" select="."/>
			<xsl:if test="@cols">
				<xsl:attribute name="colspan" select="@cols"/>
			</xsl:if>
			<xsl:if test="@rows">
				<xsl:attribute name="rowspan" select="@rows"/>
			</xsl:if>
			<xsl:variable name="current-cell" select="."/>
			<!-- include a rendition of the preceding non-<cell> siblings as part of this <td> -->
			<xsl:apply-templates select="preceding-sibling::*[not(self::tei:cell)][following-sibling::tei:cell[1] is $current-cell]"/>
			<xsl:apply-templates mode="create-content" select="."/>
		</td>
	</xsl:template>
</xsl:stylesheet>