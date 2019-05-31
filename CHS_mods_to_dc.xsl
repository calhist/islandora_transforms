<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="mods"
	xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dcterms="http://purl.org/dc/terms/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/1999/xlink">

	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<oai_dc:dc xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<xsl:apply-templates select="mods:mods"/>
		</oai_dc:dc>
	</xsl:template>

	<xsl:strip-space elements="*"/>
	
	<!-- Title -->
	<xsl:template match="mods:titleInfo">
		<xsl:if test="not(@type)">
			<dc:title>
				<xsl:if test="mods:nonSort">
					<xsl:value-of select="mods:nonSort"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="mods:title"/>
				<xsl:if test="mods:subTitle">
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:subTitle"/>
				</xsl:if>
			</dc:title>
		</xsl:if>
		<xsl:if test="@type='alternative'">
			<dcterms:alternative>
				<xsl:if test="mods:nonSort">
					<xsl:value-of select="mods:nonSort"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="mods:title"/>
				<xsl:if test="mods:subTitle">
					<xsl:text>: </xsl:text>
					<xsl:value-of select="mods:subTitle"/>
				</xsl:if>
			</dcterms:alternative>
		</xsl:if>
	</xsl:template>

	<!-- Creator and Contributor -->
	<xsl:template match="mods:name">
		<xsl:choose>
			<xsl:when test="mods:role/mods:roleTerm[@type='text']='Creator' or mods:role/mods:roleTerm[@type='text']='creator'">
				<dc:creator>
					<xsl:call-template name="name"/>
				</dc:creator>
			</xsl:when>
			<xsl:otherwise>
				<dc:contributor>
					<xsl:call-template name="name"/>
				</dc:contributor>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Identifiers -->
	<xsl:template match="mods:classification">
		<dc:identifier>
			<xsl:value-of select="."/>
		</dc:identifier>
	</xsl:template>

	<xsl:template match="mods:identifier[@type='local']">
		<dc:identifier>
			<xsl:value-of select="."/>
		</dc:identifier>
	</xsl:template>

	<!-- Subjects -->
	<xsl:template match="mods:subject[mods:topic | mods:name | mods:occupation | mods:geographic | mods:cartographics | mods:temporal] ">
		<xsl:for-each select="mods:topic | mods:occupation">
			<dc:subject>
				<xsl:value-of select="."/>
			</dc:subject>
		</xsl:for-each>
		<xsl:for-each select="mods:name">
			<dc:subject>
				<xsl:call-template name="name"/>
			</dc:subject>
		</xsl:for-each>

		<xsl:for-each select="mods:geographic">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/mods:coordinates">
			<dc:coverage>
				<xsl:value-of select="."/>
			</dc:coverage>
		</xsl:for-each>

		<xsl:for-each select="mods:cartographics/mods:scale">
			<dc:description>
				<xsl:value-of select="."/>
			</dc:description>
		</xsl:for-each>

		<xsl:if test="mods:temporal">
			<dc:coverage>
				<xsl:for-each select="mods:temporal">
					<xsl:value-of select="."/>
				</xsl:for-each>
			</dc:coverage>
		</xsl:if>
	</xsl:template>

	<!-- Notes -->
	<xsl:template match="mods:abstract | mods:note[not(@type='preferredCitation')]">
		<dc:description>
			<xsl:if test="@type='ownership'">
				<xsl:text>Ownership: </xsl:text>
			</xsl:if>
			<xsl:value-of select="."/>
		</dc:description>
	</xsl:template>

	<!-- Publisher and Date -->
	<xsl:template match="mods:originInfo">
		<xsl:if test="mods:publisher | mods:place/mods:placeTerm">
			<dc:publisher>
				<xsl:if test="mods:place/mods:placeTerm">
					<xsl:value-of select="mods:place/mods:placeTerm"/>
					<xsl:if test="mods:publisher">
						<xsl:text>: </xsl:text>
					</xsl:if>
				</xsl:if>
				<xsl:value-of select="mods:publisher"/>
			</dc:publisher>
		</xsl:if>

		<xsl:for-each select="mods:dateIssued | mods:dateCreated">
			<xsl:if test="not(@encoding='w3cdtf')">
				<dc:date>
					<xsl:value-of select="."/>
				</dc:date>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Type/Genre -->
	<xsl:template match="mods:typeOfResource">
		<xsl:if test="@collection='yes'">
			<dc:type>Collection</dc:type>
		</xsl:if>
		<xsl:if test=". ='software' and ../mods:genre='database'">
			<dc:type>Dataset</dc:type>
		</xsl:if>
		<xsl:if test=".='software' and ../mods:genre='online system or service'">
			<dc:type>Service</dc:type>
		</xsl:if>
		<xsl:if test=".='software'">
			<dc:type>Software</dc:type>
		</xsl:if>
		<xsl:if test=".='cartographic'">
			<dc:type>Image</dc:type>
		</xsl:if>
		<xsl:if test=".='multimedia'">
			<dc:type>InteractiveResource</dc:type>
		</xsl:if>
		<xsl:if test=".='moving image'">
			<dc:type>MovingImage</dc:type>
		</xsl:if>
		<xsl:if test=".='three dimensional object'">
			<dc:type>PhysicalObject</dc:type>
		</xsl:if>
		<xsl:if test="starts-with(.,'sound recording')">
			<dc:type>Sound</dc:type>
		</xsl:if>
		<xsl:if test=".='still image'">
			<dc:type>StillImage</dc:type>
		</xsl:if>
		<xsl:if test=". ='text'">
			<dc:type>Text</dc:type>
		</xsl:if>
		<xsl:if test=".='notated music'">
			<dc:type>Text</dc:type>
		</xsl:if>
	</xsl:template>

	<!-- Form, Format, Extent -->
	<xsl:template match="mods:physicalDescription">
		<xsl:for-each select="mods:extent">
			<dc:format>
				<xsl:value-of select="."/>
			</dc:format>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="mods:genre">
		<dc:format>
			<xsl:value-of select="."/>
		</dc:format>
	</xsl:template>

	<!-- Related Item, Parent Collection -->
	<xsl:template match="mods:mods/mods:relatedItem[mods:titleInfo | mods:name | mods:identifier | mods:location]">
		<xsl:choose>
			<xsl:when test="@type='original'">
				<dc:source>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:physicalLocation">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:source>
			</xsl:when>
			<xsl:when test="@type='series'"/>
			<xsl:otherwise>
				<dc:relation>
					<xsl:for-each
						select="mods:titleInfo/mods:title | mods:identifier | mods:location/mods:physicalLocation">
						<xsl:if test="normalize-space(.)!= ''">
							<xsl:value-of select="."/>
							<xsl:if test="position()!=last()">, </xsl:if>
						</xsl:if>
					</xsl:for-each>
				</dc:relation>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Rights -->
	<xsl:template match="mods:accessCondition">
		<dc:rights>
			<xsl:if test="@xlink:href">
				<xsl:value-of select="."/>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="@xlink:href"/>
			</xsl:if>
			<xsl:if test="not(@xlink:href)">
				<xsl:value-of select="."/>
			</xsl:if>
		</dc:rights>
	</xsl:template>

	<!-- Name Template -->
	<xsl:template name="name">
		<xsl:variable name="name">
			<xsl:for-each select="mods:namePart[not(@type)]">
				<xsl:value-of select="."/>
			</xsl:for-each>
			<xsl:value-of select="mods:namePart[@type='family']"/>
			<xsl:if test="mods:namePart[@type='given']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='given']"/>
			</xsl:if>
			<xsl:if test="mods:namePart[@type='date']">
				<xsl:text>, </xsl:text>
				<xsl:value-of select="mods:namePart[@type='date']"/>
			</xsl:if>
			<xsl:if test="mods:displayForm">
				<xsl:text> (</xsl:text>
				<xsl:value-of select="mods:displayForm"/>
				<xsl:text>) </xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="normalize-space($name)"/>
	</xsl:template>

	<!-- suppress all else:-->
	<xsl:template match="text()"/>
		
</xsl:stylesheet>
