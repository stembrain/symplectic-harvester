<!-- <?xml version="1.0"?> -->
<!-- Header information for the Style Sheet The style sheet requires xmlns 
	for each prefix you use in constructing the new elements -->
<xsl:stylesheet version="2.0"
	xmlns:svo="http://www.symplectic.co.uk/vivo/" xmlns:api="http://www.symplectic.co.uk/publications/api"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:core="http://vivoweb.org/ontology/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:score='http://vivoweb.org/ontology/score#' xmlns:bibo='http://purl.org/ontology/bibo/'
	xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>

	<!-- This will create indenting in xml readers -->
	<xsl:output method="xml" indent="yes" />
	<xsl:variable name="baseURI">http://vivo.tfd.co.uk/individual/</xsl:variable>

	<xsl:template match="/svo:object/api:object[@category='user']">
		<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
			xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:skos='http://www.w3.org/2008/05/skos#'
			xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:owl='http://www.w3.org/2002/07/owl#'
			xmlns:vocab='http://purl.org/vocab/vann/' xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
			xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
			xmlns:core='http://vivoweb.org/ontology/core#' xmlns:foaf='http://xmlns.com/foaf/0.1/'
			xmlns:score='http://vivoweb.org/ontology/score#' xmlns:xs='http://www.w3.org/2001/XMLSchema#'
			xmlns:svo='http://www.symplectic.co.uk/vivo/' xmlns:api='http://www.symplectic.co.uk/publications/api'
			xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>
			
			<!--  Main user object -->
		    <rdf:Description rdf:about="{$baseURI}user{@id}">
		    	<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
				<score:email>
					<xsl:value-of select="api:email-address" />
				</score:email>
				<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person" />
				<rdfs:label>
					<xsl:value-of select="api:last-name" />, <xsl:value-of select="api:first-name" />
				</rdfs:label>
				<foaf:lastName>
					<xsl:value-of select="api:last-name" />
				</foaf:lastName>
				<score:foreName>
					<xsl:value-of select="api:first-name" />
				</score:foreName>
				<score:initials>
					<xsl:value-of select="api:initials" />
				</score:initials>
				<rdf:type rdf:resource="http://vivoweb.org/harvester/excludeEntity" />
				<rdf:type
					rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag1Value1Thing" />
				<rdf:type
					rdf:resource="http://www.symplectic.co.uk/vivo/User" />
				<xsl:apply-templates select="api:organisation-defined-data" />
			</rdf:Description>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="/svo:object/api:object[@category='publication']">
		<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
			xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:skos='http://www.w3.org/2008/05/skos#'
			xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:owl='http://www.w3.org/2002/07/owl#'
			xmlns:vocab='http://purl.org/vocab/vann/' xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
			xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
			xmlns:core='http://vivoweb.org/ontology/core#' xmlns:foaf='http://xmlns.com/foaf/0.1/'
			xmlns:score='http://vivoweb.org/ontology/score#' xmlns:xs='http://www.w3.org/2001/XMLSchema#'
			xmlns:svo='http://www.symplectic.co.uk/vivo/' xmlns:api='http://www.symplectic.co.uk/publications/api'
			xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>
			<!--  Main publication object -->
		    <rdf:Description rdf:about="{$baseURI}publication{@id}">
				<xsl:choose>
					<xsl:when test="@type-id=5">
    					<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
    					<rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
    					<rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
    					<rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
    					<rdf:type rdf:resource="http://purl.org/ontology/bibo/AcademicArticle"/>
					</xsl:when>
					<xsl:otherwise>
    					<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
    					<rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
					    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
    					<rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
					</xsl:otherwise>
				</xsl:choose>	    	 
                <xsl:if test="api:records/api:record[1]/api:native/api:field[@name='publication-date']/api:date">
				   <core:dateTimeValue rdf:resource="{$baseURI}publication{@id}-publicationDate"/>
                </xsl:if>
				
				<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
				<xsl:apply-templates select="api:records/api:record[1]" />
		    </rdf:Description>
		    
		    <!--  publication date -->
            <xsl:if test="api:records/api:record[1]/api:native/api:field[@name='publication-date']/api:date">
		      <rdf:Description  rdf:about="{$baseURI}publication{@id}-publicationDate">
		        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
		    	<xsl:apply-templates select="api:records/api:record[1]/api:native/api:field[@name='publication-date']"  mode="dateTimeValue" />
		      </rdf:Description>
            </xsl:if>
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="/svo:relationship/api:relationship">
		<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
			xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:skos='http://www.w3.org/2008/05/skos#'
			xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:owl='http://www.w3.org/2002/07/owl#'
			xmlns:vocab='http://purl.org/vocab/vann/' xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
			xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
			xmlns:core='http://vivoweb.org/ontology/core#' xmlns:foaf='http://xmlns.com/foaf/0.1/'
			xmlns:score='http://vivoweb.org/ontology/score#' xmlns:xs='http://www.w3.org/2001/XMLSchema#'
			xmlns:svo='http://www.symplectic.co.uk/vivo/' xmlns:api='http://www.symplectic.co.uk/publications/api'
			xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>
		     <!--  create the link -->
		    <rdf:Description rdf:about="{$baseURI}authorship{@id}">
    			<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
				<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
				<svo:relationship-type><xsl:value-of select="@type-id" /></svo:relationship-type>
			</rdf:Description>			
			
		</rdf:RDF>
	</xsl:template>

	<xsl:template match="/svo:relationship/api:relationship[@type-id=8]">
	   <!--  author relationship -->
		<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
			xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:skos='http://www.w3.org/2008/05/skos#'
			xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:owl='http://www.w3.org/2002/07/owl#'
			xmlns:vocab='http://purl.org/vocab/vann/' xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
			xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
			xmlns:core='http://vivoweb.org/ontology/core#' xmlns:foaf='http://xmlns.com/foaf/0.1/'
			xmlns:score='http://vivoweb.org/ontology/score#' xmlns:xs='http://www.w3.org/2001/XMLSchema#'
			xmlns:svo='http://www.symplectic.co.uk/vivo/' xmlns:api='http://www.symplectic.co.uk/publications/api'
			xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>
			
			<xsl:variable name="publicationID" select="api:related[@direction='from']/api:object/@id" />
			<xsl:variable name="userID" select="api:related[@direction='to']/api:object/@id" />

            <!--  add the authorship to the person -->
		    <rdf:Description rdf:about="{$baseURI}user{$userID}">
				<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person" />
				<core:authorInAuthorship rdf:resource="{$baseURI}authorship{@id}"/>
		    </rdf:Description>

			<!--  add the author to the publication -->
		    <rdf:Description rdf:about="{$baseURI}publication{$publicationID}">
               <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
               <core:informationResourceInAuthorship rdf:resource="{$baseURI}authorship{@id}"/>
    		</rdf:Description>

		     <!--  create the link -->
		    <rdf:Description rdf:about="{$baseURI}authorship{@id}">
    			<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
    			<rdf:type rdf:resource="http://vivoweb.org/ontology/core#Relationship"/>
    			<rdf:type rdf:resource="http://vivoweb.org/ontology/core#Authorship"/>
				<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
    			<core:linkedAuthor rdf:resource="{$baseURI}user{$userID}"/>
    			<core:linkedInformationResource rdf:resource="{$baseURI}publication{$publicationID}"/>
			</rdf:Description>			
		</rdf:RDF>
	</xsl:template>


	<xsl:template match="text()"></xsl:template>
	<xsl:template match="text()" mode="dateTimeValue"></xsl:template>

    <!--  user metadata  -->
	<xsl:template match="api:organisation-defined-data[@field-name='UoA']">
		<svo:UoA>
			<xsl:value-of select="." />
		</svo:UoA>
	</xsl:template>

	<xsl:template match="api:organisation-defined-data[@field-name='Birth date']">
		<svo:BirthDate>
			<xsl:value-of select="." />
		</svo:BirthDate>
	</xsl:template>

	<xsl:template
		match="api:organisation-defined-data[@field-name='Staff category (RAE)']">
		<svo:StaffCategory>
			<xsl:value-of select="." />
		</svo:StaffCategory>
	</xsl:template>


	<!-- core publication metadata -->
	<xsl:template match="api:field[@name='title']">
		<rdfs:label>
			<xsl:value-of select="api:text" />
		</rdfs:label>
		<core:Title>
			<xsl:value-of select="api:text" />
		</core:Title>
	</xsl:template>
	<xsl:template match="api:field[@name='abstract']">
		<bibo:abstract>
			<xsl:value-of select="api:text" />
		</bibo:abstract>
	</xsl:template>
	<xsl:template match="api:field[@name='author-url']">
		<svo:author-url>
			<xsl:value-of select="api:text" />
		</svo:author-url>
	</xsl:template>
	<xsl:template match="api:field[@name='series']">
		<bibo:number>
			<xsl:value-of select="api:text" />
		</bibo:number>
	</xsl:template>
	<xsl:template match="api:field[@name='edition']">
		<bibo:edition>
			<xsl:value-of select="api:text" />
		</bibo:edition>
	</xsl:template>
	<xsl:template match="api:field[@name='volume']">
		<bibo:volume>
			<xsl:value-of select="api:text" />
		</bibo:volume>
	</xsl:template>
	<!--  Need a home for this
	 -->
	<xsl:template match="api:field[@name='pagination']">
		<xsl:choose>
		   <xsl:when test="string(api:begin-page) and string(api:end-page)">
			<svo:pagnation begin-page="{api:begin-page}" end-page="{api:end-page}" />
		   </xsl:when>
		   <xsl:when test="string(api:begin-page)">
			<svo:pagnation begin-page="{api:begin-page}" />
		   </xsl:when>
		   <xsl:when test="string(api:end-page)">
			<svo:pagnation end-page="{api:end-page}" />
		   </xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- 
	<xsl:template match="api:begin-page">
		<svo:begin-page>
			<xsl:value-of select="." />
		</svo:begin-page>
	</xsl:template>
	<xsl:template match="api:end-page">
		<svo:end-page>
			<xsl:value-of select="." />
		</svo:end-page>
	</xsl:template>
	 -->
	<xsl:template match="api:field[@name='publisher']">
		<svo:publisher>
			<xsl:value-of select="api:text" />
		</svo:publisher>
	</xsl:template>
	<xsl:template match="api:field[@name='publisher-url']">
		<svo:publisher-url>
			<xsl:value-of select="api:text" />
		</svo:publisher-url>
	</xsl:template>
	<xsl:template match="api:field[@name='place-of-publication']">
		<bibo:placeOfPublication>
			<xsl:value-of select="api:text" />
		</bibo:placeOfPublication>
	</xsl:template>
	<xsl:template match="api:field[@name='authors']">
		<svo:authors>
			<xsl:apply-templates select="api:people" />
		</svo:authors>
	</xsl:template>
	<xsl:template match="api:field[@name='editors']">
		<svo:editors>
			<xsl:apply-templates select="api:people" />
		</svo:editors>
	</xsl:template>
	
	
	<xsl:template match="api:date" mode="dateTimeValue">
		<xsl:variable name="datePrecision">
			<xsl:choose>
				<xsl:when
					test="string(api:day) and string(api:month) and string(api:year)">yearMonthDayPrecision</xsl:when>
				<xsl:when test="string(api:month) and string(api:year)">yearMonthPrecision</xsl:when>
				<xsl:when test="string(api:year)">yearPrecision</xsl:when>
				<xsl:otherwise>none</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="month">
			<xsl:choose>
				<xsl:when
					test="string-length(api:month)=1">0<xsl:value-of select="api:month" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="api:month" /></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="aboutURI">
			<xsl:choose>
			<xsl:when test="$datePrecision='yearMonthDayPrecision'" >pub/daymonthyear<xsl:value-of select="api:year" /><xsl:value-of select="$month" /><xsl:value-of select="api:day" /></xsl:when>
			<xsl:when test="$datePrecision='yearMonthPrecision'" >pub/monthyear<xsl:value-of select="api:year" /><xsl:value-of select="$month" /></xsl:when>
			<xsl:when test="$datePrecision='yearPrecision'" >pub/year<xsl:value-of select="api:year" /></xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:if test="$datePrecision!='none'">
			<core:dateTimePrecision
				rdf:resource="http://vivoweb.org/ontology/core#{$datePrecision}" />
			<core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
				<xsl:choose>
					<xsl:when test="$datePrecision='yearMonthDayPrecision'" ><xsl:value-of select="api:year" />-<xsl:value-of select="$month" />-<xsl:value-of select="api:day" />T00:00:00Z</xsl:when>
					<xsl:when test="$datePrecision='yearMonthPrecision'" ><xsl:value-of select="api:year" />-<xsl:value-of select="$month" />-01T00:00:00Z</xsl:when>
					<xsl:when test="$datePrecision='yearPrecision'" ><xsl:value-of select="api:year" />-01-01T00:00:00Z</xsl:when>
				</xsl:choose>
			</core:dateTime>
		</xsl:if>		
	</xsl:template>
	
	<xsl:template match="api:field[@name='isbn-10']">
		<bibo:isbn-10>
			<xsl:value-of select="api:text" />
		</bibo:isbn-10>
	</xsl:template>
	<xsl:template match="api:field[@name='isbn-13']">
		<bibo:isbn-13>
			<xsl:value-of select="api:text" />
		</bibo:isbn-13>
	</xsl:template>
	<xsl:template match="api:field[@name='doi']">
		<bibo:doi>
			<xsl:value-of select="api:text" />
		</bibo:doi>
	</xsl:template>
	<xsl:template match="api:field[@name='medium']">
		<svo:medium>
			<xsl:value-of select="api:text" />
		</svo:medium>
	</xsl:template>
	<xsl:template match="api:field[@name='medium']">
		<bibo:status>
			<xsl:value-of select="api:text" />
		</bibo:status>
	</xsl:template>
	<xsl:template match="api:field[@name='issn']">
		<bibo:ISSN>
			<xsl:value-of select="api:text" />
		</bibo:ISSN>
	</xsl:template>
	<xsl:template match="api:field[@name='notes']">
		<svo:notes>
			<xsl:value-of select="api:text" />
		</svo:notes>
	</xsl:template>

	<xsl:template match="api:keyword">
		<core:freetextKeyword>
			<xsl:value-of select="." />
		</core:freetextKeyword>
	</xsl:template>


	<!-- book chapter, but could also be all sorts of other things, need to 
		look at the category to work out which -->
	<xsl:template match="api:field[@name='number']">
		<xsl:choose>
			<xsl:when test="ancestor::api:object[@category='chapter']">
				<bibo:chapter>
					<xsl:value-of select="api:text" />
				</bibo:chapter>
			</xsl:when>
			<xsl:when test="ancestor::api:object[@category='journal']">
				<svo:journal-number>
					<xsl:value-of select="api:text" />
				</svo:journal-number>
			</xsl:when>
			<xsl:when test="ancestor::api:object[@category='patent']">
				<svo:application-number>
					<xsl:value-of select="api:text" />
				</svo:application-number>
			</xsl:when>
			<xsl:when test="ancestor::api:object[@category='report']">
				<svo:report-number>
					<xsl:value-of select="api:text" />
				</svo:report-number>
			</xsl:when>
		</xsl:choose>
	</xsl:template>



	<xsl:template match="api:text" mode="symJournalRef">
		<core:hasPublicationVenue rdf:resource="{$baseURI}journal{.}" />
	</xsl:template>

</xsl:stylesheet>
