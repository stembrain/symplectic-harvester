<?xml version="1.0" encoding="UTF-8"?>
<!-- 
   | Copyright (c) 2011 Ian Boston for Symplectic, relicensed under the AGPL license in repository https://github.com/ieb/symplectic-harvester
   | Please see the LICENSE file for more details
 -->
<xsl:stylesheet version="2.0"
	xmlns:svo="http://www.symplectic.co.uk/vivo/" xmlns:api="http://www.symplectic.co.uk/publications/api"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:core="http://vivoweb.org/ontology/core#" xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:score='http://vivoweb.org/ontology/score#' xmlns:bibo='http://purl.org/ontology/bibo/'
	xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'>

	<!-- This will create indenting in xml readers -->
	<xsl:variable name="baseURI">http://changeme/to/match/vivo/deploy/properties</xsl:variable>
	<xsl:output method="xml" encoding="UTF-8" indent="yes" />

	<xsl:template match="/svo:object/api:object[@category='user']">
			<rdf:RDF xmlns:owlPlus='http://www.w3.org/2006/12/owl2-xml#'
				xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:skos='http://www.w3.org/2008/05/skos#'
				xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' xmlns:owl='http://www.w3.org/2002/07/owl#'
				xmlns:vocab='http://purl.org/vocab/vann/' xmlns:swvocab='http://www.w3.org/2003/06/sw-vocab-status/ns#'
				xmlns:dc='http://purl.org/dc/elements/1.1/' xmlns:vitro='http://vitro.mannlib.cornell.edu/ns/vitro/0.7#'
				xmlns:core='http://vivoweb.org/ontology/core#' xmlns:foaf='http://xmlns.com/foaf/0.1/'
				xmlns:score='http://vivoweb.org/ontology/score#' xmlns:xs='http://www.w3.org/2001/XMLSchema#'
				xmlns:svo='http://www.symplectic.co.uk/vivo/' xmlns:api='http://www.symplectic.co.uk/publications/api'
				xmlns:vitro-public="http://vitro.mannlib.cornell.edu/ns/vitro/public#"
				xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
				xmlns:bibo='http://purl.org/ontology/bibo/'>
        <xsl:if test="api:organisation-defined-data[@field-name='Is Academic']='1'">
				
				<!--  Main user object -->
			    <rdf:Description rdf:about="{$baseURI}{@username}">
			    	<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
					<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person" />
					<rdfs:label>
						<xsl:value-of select="api:last-name" />, <xsl:value-of select="api:first-name" />
					</rdfs:label>
					<core:preferredTitle>
					   <xsl:value-of select="api:title" />
                    </core:preferredTitle>
                      <core:primaryEmail>
                       <xsl:value-of select="api:email-address" />
                      </core:primaryEmail>
					<foaf:lastName>
						<xsl:value-of select="api:last-name" />
					</foaf:lastName>
					<foaf:firstName>
						<xsl:value-of select="api:first-name" />
					</foaf:firstName>
					<score:initials>
						<xsl:value-of select="api:initials" />
					</score:initials>
					<rdf:type rdf:resource="http://vivoweb.org/harvester/excludeEntity" />
					<rdf:type
						rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#Flag1Value1Thing" />
					<rdf:type
						rdf:resource="http://www.symplectic.co.uk/vivo/User" />
					<vitro-public:mainImage rdf:resource="{$baseURI}{@username}-image"/>
					
					<xsl:apply-templates select="api:records/api:record[1]" mode="objectReferences" /> 
                    <xsl:apply-templates select="api:organisation-defined-data" mode="objectReferences" />
                
                    <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                    <xsl:apply-templates select="api:records/api:record[1]" />
                    <xsl:apply-templates select="api:organisation-defined-data" />
					
				</rdf:Description>
				<!--  users Icon.
				The users Icon file is expected to already be present in
				/users/{@username}.jpg with the thumbnail at /users/thumbnails/user{@username}.thumbnail.jpg
				on the server. If hosting under Apache HTTPD, re-write rules should be put in place 
				to ensure that a replacement image is created when those files are not found.
				 -->
				<rdf:Description rdf:about="{$baseURI}{@username}-image">
					<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
					<rdf:type rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/public#File"/>
					<vitro-public:downloadLocation rdf:resource="{$baseURI}{@username}-imageDownload"/>
					<vitro-public:thumbnailImage rdf:resource="{$baseURI}{@username}-imageThumbnail"/>
					<vitro-public:filename><xsl:value-of select="@username" />.jpg</vitro-public:filename>
					<vitro-public:mimeType>image/jpg</vitro-public:mimeType>
                </rdf:Description>
                <rdf:Description rdf:about="{$baseURI}{@username}-imageDownload">
                    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                    <rdf:type rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/public#FileByteStream"/>
                    <vitro-public:directDownloadUrl>    </vitro-public:directDownloadUrl>
                </rdf:Description>
                <rdf:Description rdf:about="{$baseURI}{@username}-imageThumbnail">
				    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
				    <rdf:type rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/public#File"/>
				    <vitro-public:downloadLocation rdf:resource="{$baseURI}{@username}-imageThumbnailDownload"/>
				    <vitro-public:filename><xsl:value-of select="@username" />.thumbnail.jpg</vitro-public:filename>
				    <vitro-public:mimeType>image/jpeg</vitro-public:mimeType>
				 </rdf:Description>
                 <rdf:Description rdf:about="{$baseURI}{@username}-imageThumbnailDownload">
				    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
				    <rdf:type rdf:resource="http://vitro.mannlib.cornell.edu/ns/vitro/public#FileByteStream"/>
				    <vitro-public:directDownloadUrl>/users/thumbnails/<xsl:value-of select="@username" />.thumbnail.jpg</vitro-public:directDownloadUrl>
				 </rdf:Description>
                <xsl:apply-templates select="api:records/api:record[1]" mode="objectEntries" /> 
                <xsl:apply-templates select="api:organisation-defined-data" mode="objectEntries" />
        </xsl:if>
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
                    <xsl:when test="@type-id=2"> <!-- Book  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Book"/>
                    </xsl:when>
                    <xsl:when test="@type-id=3"> <!-- Chapter  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Book"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Proceedings"/>
                    </xsl:when>
                    <xsl:when test="@type-id=4"> <!-- Confernce Paper  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#ConferencePaper"/>
                    </xsl:when>
                    <xsl:when test="@type-id=5"> <!--  Academic Article -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/AcademicArticle"/>
                    </xsl:when>
                    <xsl:when test="@type-id=6"> <!-- Patent  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Patent"/>
                    </xsl:when>
                    <xsl:when test="@type-id=7"> <!-- Report  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Report"/>
                    </xsl:when>
                    <xsl:when test="@type-id=8"> <!-- Software  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Software"/>
                    </xsl:when>
                    <xsl:when test="@type-id=9"> <!-- Event/Performance  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Event"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Performance"/>
                    </xsl:when>
                    <xsl:when test="@type-id=10"> <!-- Composition  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Score"/>
                    </xsl:when>
                    <xsl:when test="@type-id=13"> <!-- Exhibition  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Event"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Exhibit"/>
                    </xsl:when>
                    <xsl:when test="@type-id=15"> <!-- Internet Publication  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Webpage"/>
                    </xsl:when>
                    <xsl:when test="@type-id=16"> <!-- Scolarly Edition  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
                    </xsl:when>
                    <xsl:when test="@type-id=17"> <!-- Poster  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#ConferencePoster"/>
                    </xsl:when>
                    <xsl:when test="@type-id=18"> <!-- Thesis/Disertation  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Thesis"/>
                    </xsl:when>
                    <xsl:when test="@type-id=32"> <!-- Film  -->
                        <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                        <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/AudioVisualDocument"/>
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Film"/>
                    </xsl:when>
					<xsl:otherwise>
    					<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
    					<rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
					    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
    					<rdf:type rdf:resource="http://purl.org/ontology/bibo/Article"/>
					</xsl:otherwise>
				</xsl:choose>	    	
				<xsl:apply-templates select="api:records/api:record[1]" mode="objectReferences" /> 
				
				<ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
				<xsl:apply-templates select="api:records/api:record[1]" />
		    </rdf:Description>
		    
		    <!--  publication date -->
		    <xsl:apply-templates select="api:records/api:record[1]" mode="objectEntries" /> 
            
		</rdf:RDF>
	</xsl:template>
	


<!--

Activities.
Activities are processed via relationships since they always appear to be bound to the person who performed the activity
 -->
       <xsl:template match="api:object[@category='activity' and @type-id=24]" mode="type23">
        <!--  research themes -->
        <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
        <rdf:RDF 
            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
            xmlns:core='http://vivoweb.org/ontology/core#' 
            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
            xmlns:api='http://www.symplectic.co.uk/publications/api'
            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
            >
            <xsl:variable name="id" select="@id" />
            <!--  person -->
            <rdf:Description rdf:about="{$baseURI}{$username}" >
                <xsl:for-each select="api:records/api:record/api:native/api:field[@name='c-keywords']/api:items/api:item"> 
                     <xsl:variable name="p" select="position()" />
                     <core:hasResearchArea rdf:resource="{$baseURI}concept{$id}-{$p}" />
                </xsl:for-each>
            </rdf:Description>
            <xsl:for-each select="api:records/api:record/api:native/api:field[@name='c-keywords']/api:items/api:item"> 
                 <xsl:variable name="p" select="position()" />
	            <rdf:Description rdf:about="{$baseURI}concept{$id}-{$p}">
	                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	                <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
	                <core:researchAreaOf rdf:resource="{$baseURI}{$username}"/>
	                <rdfs:label><xsl:value-of select="."/></rdfs:label>
	                <svo:smush>concept:<xsl:value-of select="."/></svo:smush>
	            </rdf:Description>
            </xsl:for-each>
          </rdf:RDF>
       </xsl:template>

       <xsl:template match="api:object[@category='activity' and @type-id=19]" mode="type23">
          <!-- Biography -->
        <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
        <rdf:RDF 
            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
            xmlns:core='http://vivoweb.org/ontology/core#' 
            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
            xmlns:api='http://www.symplectic.co.uk/publications/api'
            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
            >
            
            <!--  person -->
            <rdf:Description rdf:about="{$baseURI}{$username}" >
	            <core:overview>
	               <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/>
	            </core:overview>
            </rdf:Description>
          </rdf:RDF>
       </xsl:template>
       <xsl:template match="api:object[@category='activity' and @type-id=20]" mode="type23">
            <!--  Qualification Award -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
        <rdf:RDF 
            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
            xmlns:core='http://vivoweb.org/ontology/core#' 
            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
            xmlns:api='http://www.symplectic.co.uk/publications/api'
            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
            >
            
            <!--  person -->
            <rdf:Description rdf:about="{$baseURI}{$username}" >
                <core:educationalTraining rdf:resource="{$baseURI}academic-degree{@id}"/>
            </rdf:Description>
            
            <rdf:Description rdf:about="{$baseURI}academic-degree{@id}">
			    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
			    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#EducationalTraining"/>
			    <core:degreeEarned rdf:resource="{$baseURI}academic-degree{@id}-degree"/>
			    <core:educationalTrainingOf rdf:resource="{$baseURI}{$username}"/>
			    <core:majorField><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-subject']/api:text"/></core:majorField>
			    <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                   <core:dateTimeValue rdf:resource="{$baseURI}academic-degree{@id}-date"/>
                </xsl:if>
                <rdfs:label>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-qualification-level']/api:text"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-subject']/api:text"/>
                </rdfs:label>			    
                <core:trainingAtOrganization rdf:resource="{$baseURI}academic-degree{@id}-org"/>
                <!-- 
                <core:departmentOrSchool>Funding organization</core:departmentOrSchool>
                <core:supplementalInformation>Post Doc training</core:supplementalInformation>
			     -->
		    </rdf:Description>
		    
            <!--  organization -->
            <rdf:Description rdf:about="{$baseURI}academic-degree{@id}-org">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#School"/>
                <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
                <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                <rdfs:label>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/>
                </rdfs:label>
                <svo:smush>organization:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/></svo:smush>
            </rdf:Description>
            
            <rdf:Description rdf:about="{$baseURI}academic-degree{@id}-degree">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#AcademicDegree"/>
                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                <core:abbreviation><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-qualification-level']/api:text"/></core:abbreviation>
                <rdfs:label>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-qualification-level']/api:text"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-subject']/api:text"/>
                </rdfs:label>
                <svo:smush>academic-degree:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-qualification-level']/api:text"/><xsl:text> </xsl:text>
                <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-subject']/api:text"/>
                </svo:smush>
             </rdf:Description>
             <!--  award date -->
              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                  <rdf:Description rdf:about="{$baseURI}academic-degree{@id}-date">
                       <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                       <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                       <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/award-date"/>
                      <core:dateTimePrecision
                             rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
                      <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                          <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-awarded-year']/api:integer" />-01-01T00:00:00Z
                      </core:dateTime>
                  </rdf:Description>
              </xsl:if>            
        </rdf:RDF>       
       </xsl:template>

       <xsl:template match="api:object[@category='activity' and @type-id=21]" mode="type23">
            <!--  Honor Award -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
	        <rdf:RDF 
	            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
	            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
	            xmlns:core='http://vivoweb.org/ontology/core#' 
	            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
	            xmlns:api='http://www.symplectic.co.uk/publications/api'
	            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
	            >
	            
	            <!--  person -->
	            <rdf:Description rdf:about="{$baseURI}{$username}" >
                    <core:awardOrHonor rdf:resource="{$baseURI}award{@id}"/>
                </rdf:Description>
	         	            
	         	<!--  award -->
	            <rdf:Description rdf:about="{$baseURI}award{@id}">
				    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
				    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#AwardReceipt"/>
                    <core:awardOrHonorFor rdf:resource="{$baseURI}{$username}"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
	              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                        <core:dateTimeValue rdf:resource="{$baseURI}award{@id}-date"/>
	              </xsl:if>
	                <rdfs:label>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-comments']/api:text"/>
	                </rdfs:label>
	                <svo:smush>award:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-comments']/api:text"/>
	                </svo:smush>
	                <!--  What do we do about award date, was not in the examples but is in the /activities/type -->
	            </rdf:Description>
	            
	              <!--  award date -->
	              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
	                  <rdf:Description rdf:about="{$baseURI}award{@id}-date">
	                       <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	                       <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
	                       <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/award-date"/>
	                      <core:dateTimePrecision
	                             rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
	                      <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
	                          <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-awarded-year']/api:integer" />-01-01T00:00:00Z
	                      </core:dateTime>
	                  </rdf:Description>
	              </xsl:if>
             
        </rdf:RDF>       
       </xsl:template>
       <xsl:template match="api:object[@category='activity' and @type-id=30]" mode="type23">
            <!--  Invited Talk -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
	        <rdf:RDF 
	            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
	            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
	            xmlns:core='http://vivoweb.org/ontology/core#' 
	            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
	            xmlns:api='http://www.symplectic.co.uk/publications/api'
	            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
	            >
	          <rdf:Description rdf:about="{$baseURI}{$username}" >
	                <core:hasPresenterRole rdf:resource="{$baseURI}invitedtalk{@id}-role"/>
	          </rdf:Description>
	            
	
	         <rdf:Description rdf:about="{$baseURI}invitedtalk{@id}-role">
			    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
			    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
			    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#PresenterRole"/>
			    <core:roleRealizedIn rdf:resource="{$baseURI}invitedtalk{@id}"/>
	            <core:presenterRoleOf rdf:resource="{$baseURI}{$username}"/>
	            <rdfs:label>Speaker</rdfs:label>
	         </rdf:Description>
	            
	          <rdf:Description rdf:about="{$baseURI}invitedtalk{@id}">
	            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Presentation"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InvitedTalk"/>
	            <rdf:type rdf:resource="http://purl.org/NET/c4dm/event.owl#Event"/>
                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                <rdfs:label>
                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/>
                </rdfs:label>
	          </rdf:Description>
	      </rdf:RDF>
       </xsl:template>
       <xsl:template match="api:object[@category='activity' and @type-id=22]" mode="type23">
       <!--  Member -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
 
        <rdf:RDF 
            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
            xmlns:core='http://vivoweb.org/ontology/core#' 
            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
            xmlns:api='http://www.symplectic.co.uk/publications/api'
            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
            >
	          <!--  person -->
	          <rdf:Description rdf:about="{$baseURI}{$username}" >
	            <core:hasMemberRole rdf:resource="{$baseURI}member{@id}-role"/>
	          </rdf:Description>
	          <!--  role -->
	          <rdf:Description rdf:about="{$baseURI}member{@id}-role">
	            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#MemberRole"/>
	            <core:roleContributesTo rdf:resource="{$baseURI}member{@id}-org"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                    <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                        <core:dateTimeValue rdf:resource="{$baseURI}role{@id}-start"/>
                    </xsl:if>
                    <xsl:if test="api:records/api:record/api:native/api:field[@name='c-end-year']" >
                        <core:dateTimeValue rdf:resource="{$baseURI}role{@id}-end"/>
                    </xsl:if>
	                <rdfs:label>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-role']/api:text"/>
	                </rdfs:label>
	          </rdf:Description>
	          <!--  organization -->
	          <rdf:Description rdf:about="{$baseURI}member{@id}-org">
			    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
			    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
			    <core:contributingRole rdf:resource="{$baseURI}member{@id}-role"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
	                <rdfs:label>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/>
	                </rdfs:label>
	                <!--  for some reason smushing this fails -->
	                <svo:smush>organization:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/>
	                </svo:smush>
	          </rdf:Description>
              
              <!--  start role -->
              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                  <rdf:Description rdf:about="{$baseURI}role{@id}-start">
                       <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                       <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                       <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/role-start"/>
                      <core:dateTimePrecision
                             rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
                      <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                          <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-awarded-year']/api:integer" />-01-01T00:00:00Z
                      </core:dateTime>
                  </rdf:Description>
              </xsl:if>
  
              <!--  end role -->
              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-end-year']" >
                  <rdf:Description rdf:about="{$baseURI}role{@id}-end">
                       <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                       <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                       <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/role-end"/>
                      <core:dateTimePrecision
                             rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
                      <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                          <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-end-year']/api:integer" />-01-01T00:00:00Z
                      </core:dateTime>
                  </rdf:Description>
              </xsl:if>
          
          
          </rdf:RDF>
	   </xsl:template>
	   
	   
	   <xsl:template match="api:object[@category='activity' and @type-id=23]" mode="type23">
	       <!--  External Responsibility -->
	        <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
	              
	        <rdf:RDF 
	            xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
	            xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
	            xmlns:core='http://vivoweb.org/ontology/core#' 
	            xmlns:svo='http://www.symplectic.co.uk/vivo/' 
	            xmlns:api='http://www.symplectic.co.uk/publications/api'
	            xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
	            >
	            
	          <!--  link to the person -->
	          <rdf:Description rdf:about="{$baseURI}{$username}">
	                <core:hasRole rdf:resource="{$baseURI}role{@id}"/>
	          </rdf:Description>
	
	
	          <!--  role -->
	          <rdf:Description rdf:about="{$baseURI}role{@id}">
	            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#MemberRole"/>
	                <core:roleContributesTo rdf:resource="{$baseURI}external{@id}-org"/>
	                <core:roleOf rdf:resource="{$baseURI}{$username}"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
	                <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
	                    <core:dateTimeValue rdf:resource="{$baseURI}role{@id}-start"/>
	                </xsl:if>
	                <xsl:if test="api:records/api:record/api:native/api:field[@name='c-end-year']" >
	                    <core:dateTimeValue rdf:resource="{$baseURI}role{@id}-end"/>
	                </xsl:if>
	                <rdfs:label>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/>
	                    <xsl:text> </xsl:text>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-role']/api:text"/>
	                </rdfs:label>                
	            </rdf:Description>
	            
	           <!--  organisation -->
	          <rdf:Description rdf:about="{$baseURI}external{@id}-org">
	            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
	            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
	            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
	            <core:contributingRole rdf:resource="{$baseURI}role{@id}"/>
	                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
	                <rdfs:label>
	                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/>
	                </rdfs:label>
	                <svo:smush>organization:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-organisation']/api:text"/>
	                </svo:smush>
	          </rdf:Description>
	          
	            
	
	            <!--  start role -->
	            <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
		            <rdf:Description rdf:about="{$baseURI}role{@id}-start">
		                 <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		                 <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
		                 <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/role-start"/>
		                <core:dateTimePrecision
		                       rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
		                <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
		                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-awarded-year']/api:integer" />-01-01T00:00:00Z
		                </core:dateTime>
		            </rdf:Description>
	            </xsl:if>
	
	            <!--  end role -->
	            <xsl:if test="api:records/api:record/api:native/api:field[@name='c-end-year']" >
		            <rdf:Description rdf:about="{$baseURI}role{@id}-end">
		                 <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		                 <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
		                 <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/role-end"/>
		                <core:dateTimePrecision
		                       rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
		                <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
		                    <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-end-year']/api:integer" />-01-01T00:00:00Z
		                </core:dateTime>
		            </rdf:Description>
	            </xsl:if>
	            
	
	
	            
	          </rdf:RDF>
	          <!-- 
	          type also has 
	          c-hyperlink,  example
	                 
	           -->
       </xsl:template>
       <xsl:template match="api:object[@category='activity' and @type-id=25]" mode="type23">
           <!--  Webpage -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <core:webpage rdf:resource="{$baseURI}webpage{@id}"/>
              </rdf:Description>
 

	        <rdf:Description rdf:about="{$baseURI}webpage{@id}">
	            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#URLLink" />
	            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing" />
	            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/author-url"/>
	            <core:webpageOf rdf:resource="{$baseURI}{$username}" />
	            <core:linkURI>
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-hyperlink']/api:text"/>
	            </core:linkURI>
	            <core:linkAnchorText>
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/>
	            </core:linkAnchorText>
                <svo:smush>
                   webpage:
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/>:
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-hyperlink']/api:text"/>
                </svo:smush>
	        </rdf:Description>
	       </rdf:RDF>
	      </xsl:template>

       <xsl:template match="api:object[@category='activity' and @type-id=26]" mode="type23">
           <!--  Social Media -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <core:webpage rdf:resource="{$baseURI}socialmedia{@id}"/>
              </rdf:Description>
 

            <rdf:Description rdf:about="{$baseURI}socialmedia{@id}">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#URLLink" />
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing" />
                <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/author-url"/>
                <core:webpageOf rdf:resource="{$baseURI}{$username}" />
                <core:linkURI>
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-hyperlink']/api:text"/>
                </core:linkURI>
                <core:linkAnchorText><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/></core:linkAnchorText>
                <svo:smush>
                   webpage:
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/>:
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-hyperlink']/api:text"/>
                </svo:smush>
            </rdf:Description>
           </rdf:RDF>
          </xsl:template>
          <xsl:template match="api:object[@category='activity' and @type-id=27]" mode="type23">
           <!--  External Responsibility -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <core:hasOutreachProviderRole rdf:resource="{$baseURI}outreach{@id}"/>
              </rdf:Description>
 

            <rdf:Description rdf:about="{$baseURI}outreach{@id}">
			    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
			    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
			    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#OutreachProviderRole"/>
			    <core:outreachProviderRoleOf rdf:resource="{$baseURI}{$username}"/>
			    <core:roleContributesTo rdf:resource="{$baseURI}outreach-external-org" />
			    <rdfs:label><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></rdfs:label>
                <!--  add properties to enable smushing -->
                <svo:smush>outreachrole:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></svo:smush>
            </rdf:Description>
            
            <!--  not enough information to be able to specify this from the Elements API -->
            <rdf:Description rdf:about="{$baseURI}outreach-external-org">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
                <core:contributingRole rdf:resource="{$baseURI}outreach{@id}"/>
                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                    <rdfs:label>External Organization</rdfs:label>
                    <svo:smush>organization:External Organization</svo:smush>
            </rdf:Description> 
           </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=28]" mode="type23">
           <!--  Profile of UG teaching -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <core:hasTeacherRole rdf:resource="{$baseURI}ugteacher{@id}"/>
              </rdf:Description>
 

            <rdf:Description rdf:about="{$baseURI}ugteacher{@id}">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#TeacherRole"/>
                <core:teacherRoleOf rdf:resource="{$baseURI}{$username}"/>
                <core:roleRealizedIn rdf:resource="{$baseURI}ugteacher{@id}-course" />
                <rdfs:label>
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/>
                </rdfs:label>
                <core:description>
                   <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/>
                </core:description>
            </rdf:Description>

            <rdf:Description rdf:about="{$baseURI}ugteacher{@id}-course">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Course"/>
                <core:realizedRole rdf:resource="{$baseURI}ugteacher{@id}" />
                <rdfs:label>
                    Undergraduate Teaching Course
                </rdfs:label>
                <!--  add properties to enable smushing -->
                <svo:smush>course:Undergraduate Teaching Course</svo:smush>
            </rdf:Description>
            
           </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=29]" mode="type23">
           <!--  Profile of PG teaching -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <core:hasTeacherRole rdf:resource="{$baseURI}pgteacher{@id}"/>
              </rdf:Description>
 

            <rdf:Description rdf:about="{$baseURI}pgteacher{@id}">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Role"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#TeacherRole"/>
                <core:teacherRoleOf rdf:resource="{$baseURI}{$username}"/>
                <core:roleRealizedIn rdf:resource="{$baseURI}pgteacher{@id}-course" />
                <rdfs:label ><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></rdfs:label>
                <core:description><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></core:description>
            </rdf:Description>

            <rdf:Description rdf:about="{$baseURI}pgteacher{@id}-course">
                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Course"/>
                <core:realizedRole rdf:resource="{$baseURI}pgteacher{@id}" />
                <rdfs:label>Post Graduate Teaching Course</rdfs:label>
                <!--  add properties to enable smushing -->
                <svo:smush>course:Post Graduate Teaching Course</svo:smush>
            </rdf:Description>
            
           </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=33]" mode="type23">
           <!--  PhD Student -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                <core:advisorIn rdf:resource="{$baseURI}graduate-student{@id}-relationship" />
              </rdf:Description>

              <rdf:Description rdf:about="{$baseURI}graduate-student{@id}-relationship">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#GraduateAdvisingRelationship"/>
                  <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                <core:advisor rdf:resource="{$baseURI}{$username}" />
                <core:advisee rdf:resource="{$baseURI}graduate-student{@id}" />
                <core:hasSubjectArea rdf:resource="{$baseURI}graduate-student{@id}-subject" />
              </rdf:Description>
              
              <rdf:Description rdf:about="{$baseURI}graduate-student{@id}">
                <rdf:type rdf:resource="http://vivoweb.org/ontology/core#GraduateStudent"/>
                <core:adviseeIn rdf:resource="{$baseURI}graduate-student{@id}-relationship" />
                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                <rdfs:label><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/></rdfs:label>
                <svo:smush>person:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-title']/api:text"/></svo:smush>               
              </rdf:Description>
              <rdf:Description rdf:about="{$baseURI}graduate-student{@id}-subject">
                  <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                  <rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
                  <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                  <rdfs:label><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></rdfs:label>
                  <svo:smush>concept:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-details']/api:text"/></svo:smush>
              </rdf:Description>            
           </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=38]" mode="type23">
           <!--  Network -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                <core:hasColaborator rdf:resource="{$baseURI}network{@id}" />
              </rdf:Description>

              <rdf:Description rdf:about="{$baseURI}network{@id}">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Group"/>
                    <core:hasColaborator rdf:resource="{$baseURI}{$username}" />
                    <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                         <core:dateTimeValue rdf:resource="{$baseURI}network{@id}-date"/>
                    </xsl:if>
              </rdf:Description>
              
              <xsl:if test="api:records/api:record/api:native/api:field[@name='c-awarded-year']" >
                  <rdf:Description rdf:about="{$baseURI}network{@id}-date">
                       <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
                       <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
                       <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/award-date"/>
                      <core:dateTimePrecision
                             rdf:resource="http://vivoweb.org/ontology/core#yearPrecision" />
                      <core:dateTime rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
                          <xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-awarded-year']/api:integer" />-01-01T00:00:00Z</core:dateTime>
                  </rdf:Description>
              </xsl:if>            
            </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=40]" mode="type23">
           <!--  School -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                <core:currentMemberOf rdf:resource="{$baseURI}school{@id}" />
              </rdf:Description>

              <rdf:Description rdf:about="{$baseURI}school{@id}">
                    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#School"/>
                    <core:hasCurrentMember rdf:resource="{$baseURI}{$username}" />
	                <rdfs:label><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-schools']/api:text"/></rdfs:label>
	                <svo:smush>organization:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-schools']/api:text"/></svo:smush>               
              </rdf:Description>
              
            </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=36]" mode="type23">
           <!--  Research Center -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
               <xsl:variable name="id" select="@id" />
                
              <!--  link to the person -->
	              <rdf:Description rdf:about="{$baseURI}{$username}">
                    <xsl:for-each select="api:records/api:record/api:native/api:field[@name='c-keywords']/api:items/api:item" >
                        <xsl:variable name="p" select="position()" />
	                   <core:currentMemberOf rdf:resource="{$baseURI}researchcenter{$id}-{$p}" />
	                </xsl:for-each>
	              </rdf:Description>
	
	              
              <xsl:for-each select="api:records/api:record/api:native/api:field[@name='c-keywords']/api:items/api:item" >
                  <xsl:variable name="p" select="position()" />
	              <rdf:Description rdf:about="{$baseURI}researchcenter{$id}-{$p}">
	                    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#ResearchOrganization"/>
	                    <core:hasCurrentMember rdf:resource="{$baseURI}{$username}" />
	                    <rdfs:label><xsl:value-of select="."/></rdfs:label>
	                    <svo:smush>organization:<xsl:value-of select="."/></svo:smush>               
	              </rdf:Description>
              </xsl:for-each>
              
            </rdf:RDF>
          </xsl:template>

          <xsl:template match="api:object[@category='activity' and @type-id=31]" mode="type23">
           <!--  Academic Group -->
            <xsl:variable name="username" select="ancestor::api:relationship/api:related[@direction='to']/api:object/@username" /> 
                  
            <rdf:RDF 
                xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                xmlns:core='http://vivoweb.org/ontology/core#' 
                xmlns:svo='http://www.symplectic.co.uk/vivo/' 
                xmlns:api='http://www.symplectic.co.uk/publications/api'
                xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                >
                
              <!--  link to the person -->
              <rdf:Description rdf:about="{$baseURI}{$username}">
                <core:currentMemberOf rdf:resource="{$baseURI}academicgroup{@id}" />
              </rdf:Description>

              <rdf:Description rdf:about="{$baseURI}academicgroup{@id}">
                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Group"/>
                    <core:hasCurrentMember rdf:resource="{$baseURI}{$username}" />
                    <rdfs:label><xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-comments']/api:text"/></rdfs:label>
                    <svo:smush>organization:<xsl:value-of select="api:records/api:record/api:native/api:field[@name='c-comments']/api:text"/></svo:smush>               
              </rdf:Description>
              
            </rdf:RDF>
          </xsl:template>
 
 <!--  Relationships -->	   
	<xsl:template match="/svo:relationship/api:relationship">
	   <xsl:choose>
		   <xsl:when test="@type-id=8" >
		   <!--  author relationship -->
				<rdf:RDF
                    xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                    xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                    xmlns:core='http://vivoweb.org/ontology/core#' 
                    xmlns:api='http://www.symplectic.co.uk/publications/api'
                    xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                    >
					
					<xsl:variable name="publicationID" select="api:related[@direction='from']/api:object/@id" />
					<xsl:variable name="userID" select="api:related[@direction='to']/api:object/@username" />
		
		            <!--  add the authorship to the person -->
				    <rdf:Description rdf:about="{$baseURI}{$userID}">
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
		    			<core:linkedAuthor rdf:resource="{$baseURI}{$userID}"/>
		    			<core:linkedInformationResource rdf:resource="{$baseURI}publication{$publicationID}"/>
					</rdf:Description>			
				</rdf:RDF>
	       </xsl:when>
           <xsl:when test="@type-id=9" >
           <!--  editor relationship -->
                <rdf:RDF 
                    xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                    xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                    xmlns:core='http://vivoweb.org/ontology/core#' 
                    xmlns:api='http://www.symplectic.co.uk/publications/api'
                    xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                    >
                    
                    <xsl:variable name="publicationID" select="api:related[@direction='from']/api:object/@id" />
                    <xsl:variable name="userID" select="api:related[@direction='to']/api:object/@username" />
        
        
                    <!--  add the author to the publication -->
                    <rdf:Description rdf:about="{$baseURI}publication{$publicationID}">
                        <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
                       <rdf:type rdf:resource="http://purl.org/ontology/bibo/Document"/>
                       <core:editor rdf:resource="{$baseURI}{$userID}"/>
                    </rdf:Description>
        
                </rdf:RDF>
           </xsl:when>
           <xsl:when test="@type-id=17" >
             <!--  (Grant) Funder of (User) eg relationship30585 -->
           </xsl:when>
           <xsl:when test="@type-id=43" >
              <!-- (User) Primary investigator (Grant) relationship30586 -->
           </xsl:when>
           <xsl:when test="@type-id=44" >
              <!-- (User) Secondary investigator (Grant) relationship30587 -->
           </xsl:when>
           <xsl:when test="@type-id=23" >
               <xsl:apply-templates select="." mode="type23"/>
           </xsl:when>
	       <xsl:otherwise>
		        <rdf:RDF 
                    xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' 
                    xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#' 
                    xmlns:core='http://vivoweb.org/ontology/core#' 
                    xmlns:api='http://www.symplectic.co.uk/publications/api'
                    xmlns:ufVivo='http://vivo.ufl.edu/ontology/vivo-ufl/'
                    >
		             <!--  create the link -->
		            <rdf:Description rdf:about="{$baseURI}-unknown-relationship-{@id}">
		                <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		                <ufVivo:harvestedBy>Symplectic-Harvester</ufVivo:harvestedBy>
		                <svo:relationship-type><xsl:value-of select="@type-id" /></svo:relationship-type>
		            </rdf:Description>          
		            
		        </rdf:RDF>
	       </xsl:otherwise>
        </xsl:choose>
	</xsl:template>


	<xsl:template match="text()"></xsl:template>
	<xsl:template match="text()" mode="dateTimeValue"></xsl:template>
    <xsl:template match="text()" mode="objectReferences"></xsl:template>
    <xsl:template match="text()" mode="objectEntries"></xsl:template>
    <xsl:template match="text()" mode="type23"></xsl:template>

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

    <xsl:template
        match="api:organisation-defined-data[@field-name='Telephone Number']">
        <core:phoneNumber>
            <xsl:value-of select="." />
        </core:phoneNumber>
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
		   <xsl:when test="string(api:pagination/api:begin-page) and string(api:pagination/api:end-page)">
		    <bibo:pageStart><xsl:value-of select="api:pagination/api:begin-page" /></bibo:pageStart>
		    <bibo:pageEnd><xsl:value-of select="api:pagination/api:end-page" /></bibo:pageEnd>
		   </xsl:when>
		   <xsl:when test="string(api:pagination/api:begin-page)">
            <bibo:pageStart><xsl:value-of select="api:pagination/api:begin-page" /></bibo:pageStart>
		   </xsl:when>
		   <xsl:when test="string(api:pagination/api:end-page)">
            <bibo:pageEnd><xsl:value-of select="api:pagination/api:end-page" /></bibo:pageEnd>
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
	<!--  TODO: convert this to core:publisher link t foaf:Organization -->
		<svo:publisher>
			<xsl:value-of select="api:text" />
		</svo:publisher>
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

    <xsl:template match="api:field[@name='eISSN']">
        <bibo:eissn>
            <xsl:value-of select="api:text" />
        </bibo:eissn>
    </xsl:template>

    <xsl:template match="api:field[@name='book-title']">
        <svo:book-title>
            <xsl:value-of select="api:text" />
        </svo:book-title>
    </xsl:template>

    <xsl:template match="api:field[@name='chapter-number']">
        <svo:chapter-number>
            <xsl:value-of select="api:text" />
        </svo:chapter-number>
    </xsl:template>



    <xsl:template match="api:field[@name='country']">
        <svo:country>
            <xsl:value-of select="api:text" />
        </svo:country>
    </xsl:template>
    <xsl:template match="api:field[@name='confidential-report']">
        <svo:confidential-report>
            <xsl:value-of select="api:text" />
        </svo:confidential-report>
    </xsl:template>
    
    <xsl:template match="api:field[@name='confidential']">
        <svo:confidential>
            <xsl:value-of select="api:text" />
        </svo:confidential>
    </xsl:template>
    
 
    <xsl:template match="api:field[@name='event-title']">
        <svo:event-title>
            <xsl:value-of select="api:text" />
        </svo:event-title>
    </xsl:template>
    <xsl:template match="api:field[@name='event-type']">
        <svo:event-type>
            <xsl:value-of select="api:text" />
        </svo:event-type>
    </xsl:template>
 
    <xsl:template match="api:field[@name='issue']">
        <bibo:issue>
            <xsl:value-of select="api:text" />
        </bibo:issue>
    </xsl:template>
    <xsl:template match="api:field[@name='identification-number']">
        <bibo:number>
            <xsl:value-of select="api:text" />
        </bibo:number>
    </xsl:template>
    <xsl:template match="api:field[@name='language']">
        <svo:language>
            <xsl:value-of select="api:text" />
        </svo:language>
    </xsl:template>
    <xsl:template match="api:field[@name='location']">
        <svo:location>
            <xsl:value-of select="api:text" />
        </svo:location>
    </xsl:template>
    <xsl:template match="api:field[@name='location-of-work']">
        <svo:location-of-work>
            <xsl:value-of select="api:text" />
        </svo:location-of-work>
    </xsl:template>
    <xsl:template match="api:field[@name='c-monograph-type']">
        <svo:monograph-type>
            <xsl:value-of select="api:text" />
        </svo:monograph-type>
    </xsl:template>
    <xsl:template match="api:field[@name='name-of-conference']">
        <svo:name-of-conference>
            <xsl:value-of select="api:text" />
        </svo:name-of-conference>
    </xsl:template>
    <xsl:template match="api:field[@name='number-of-chapters']">
        <svo:number-of-chapters>
            <xsl:value-of select="api:text" />
        </svo:number-of-chapters>
    </xsl:template>
    <xsl:template match="api:field[@name='number-of-pieces']">
        <svo:number-of-pieces>
            <xsl:value-of select="api:text" />
        </svo:number-of-pieces>
    </xsl:template>
    <xsl:template match="api:field[@name='pii']">
        <svo:pii>
            <xsl:value-of select="api:text" />
        </svo:pii>
    </xsl:template>
    <xsl:template match="api:field[@name='patent-number']">
        <svo:patent-number>
            <xsl:value-of select="api:text" />
        </svo:patent-number>
    </xsl:template>
    <xsl:template match="api:field[@name='patent-status']">
        <svo:patent-status>
            <xsl:value-of select="api:text" />
        </svo:patent-status>
    </xsl:template>
    <xsl:template match="api:field[@name='presentation-type']">
        <presentation-type>
            <xsl:value-of select="api:text" />
        </presentation-type>
    </xsl:template>
    <xsl:template match="api:field[@name='producers']">
        <svo:producers>
            <xsl:value-of select="api:text" />
        </svo:producers>
    </xsl:template>    
    <xsl:template match="api:field[@name='published-proceedings']">
        <svo:published-proceedings>
            <xsl:value-of select="api:text" />
        </svo:published-proceedings>
    </xsl:template>
    <xsl:template match="api:field[@name='refereed']">
<!--  TODO:                <bibo:status rdf:resource="http://purl.org/ontology/bibo/peerReviewed"/> -->
        <svo:refereed>
            <xsl:value-of select="api:text" />
        </svo:refereed>
    </xsl:template>
    <xsl:template match="api:field[@name='references']">
<!--  TODO: bibo:cites ?, may be a reference rather than a property -->
        <svo:references>
            <xsl:value-of select="api:text" />
        </svo:references>
    </xsl:template>
    <xsl:template match="api:field[@name='report-number']">
        <bibo:number>
            <xsl:value-of select="api:text" />
        </bibo:number>
    </xsl:template>
    <xsl:template match="api:field[@name='report-title']">
        <svo:report-title>
            <xsl:value-of select="api:text" />
        </svo:report-title>
    </xsl:template>
    <xsl:template match="api:field[@name='running-time']">
        <svo:running-time>
            <xsl:value-of select="api:text" />
        </svo:running-time>
    </xsl:template>
    <xsl:template match="api:field[@name='series-directors']">
        <svo:series-directors>
            <xsl:value-of select="api:text" />
        </svo:series-directors>
    </xsl:template>
    <xsl:template match="api:field[@name='size']">
        <svo:size>
            <xsl:value-of select="api:text" />
        </svo:size>
    </xsl:template>
    <xsl:template match="api:field[@name='status']">
        <xsl:choose>
            <xsl:when test="api:text='accepted'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/accepted"/>
            </xsl:when>
            <xsl:when test="api:text='draft'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/draft"/>
            </xsl:when>
            <xsl:when test="api:text='in press'">
                <bibo:status rdf:resource="http://vivoweb.org/ontology/core#inPress"/>
            </xsl:when>
            <xsl:when test="api:text='invited'">
                <bibo:status rdf:resource="http://vivoweb.org/ontology/core#invited"/>
            </xsl:when>
            <xsl:when test="api:text='peer reviewed'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/peerReviewed"/>
            </xsl:when>
            <xsl:when test="api:text='published'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/published"/>
            </xsl:when>
            <xsl:when test="api:text='rejected'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/rejected"/>
            </xsl:when>
            <xsl:when test="api:text='submitted'">
                <bibo:status rdf:resource="http://vivoweb.org/ontology/core#submitted"/>
            </xsl:when>
            <xsl:when test="api:text='unpublished'">
                <bibo:status rdf:resource="http://purl.org/ontology/bibo/unpublished"/>
            </xsl:when>
            <xsl:otherwise>
                <bibo:status rdf:resource="http://www.symplectic.co.uk/vivo/status/{api:text}"/>
            </xsl:otherwise>
        </xsl:choose>
        <svo:status>
            <xsl:value-of select="api:text" />
        </svo:status>
    </xsl:template>
    <xsl:template match="api:field[@name='sub-types']">
        <svo:sub-types>
            <xsl:value-of select="api:text" />
        </svo:sub-types>
    </xsl:template>
    <xsl:template match="api:field[@name='territory']">
        <svo:territory>
            <xsl:value-of select="api:text" />
        </svo:territory>
    </xsl:template>
    <xsl:template match="api:field[@name='transmission']">
        <svo:transmission>
            <xsl:value-of select="api:text" />
        </svo:transmission>
    </xsl:template>
    <xsl:template match="api:field[@name='type-of-work']">
        <svo:type-of-work>
            <xsl:value-of select="api:text" />
        </svo:type-of-work>
    </xsl:template>
    <xsl:template match="api:field[@name='venue']">
        <svo:venue>
            <xsl:value-of select="api:text" />
        </svo:venue>
    </xsl:template>
    <xsl:template match="api:field[@name='version']">
        <svo:version>
            <xsl:value-of select="api:text" />
        </svo:version>
    </xsl:template>
    
    
    

	<xsl:template match="api:keyword">
		<core:freetextKeyword>
			<xsl:value-of select="." />
		</core:freetextKeyword>
	</xsl:template>


	<!-- book chapter, but could also be all sorts of other things, need to 
		look at the category to work out which -->
	<xsl:template match="api:field[@name='number']">
		<bibo:number>
			<xsl:value-of select="api:text" />
		</bibo:number>
	</xsl:template>



	<xsl:template match="api:text" mode="symJournalRef">
		<core:hasPublicationVenue rdf:resource="{$baseURI}journal{.}" />
	</xsl:template>
	
	
    <xsl:template match="api:field[@name='publication-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-publicationDate"/>
    </xsl:template>


    <xsl:template match="api:field[@name='publication-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-publicationDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/publication-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>
    
    <xsl:template match="api:field[@name='start-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-startDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='start-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-startDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/start-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='presented-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-presentedDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='presented-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-presentedDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/presented-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='filed-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-filedDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='filed-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-filedDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/filed-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='expiry-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-expiryDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='expiry-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-expiryDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/expiry-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>
    
    <xsl:template match="api:field[@name='end-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-endDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='end-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-endDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/end-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-date"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-date">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='date-submitted']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-dateSubmitted"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='date-submitted']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-dateSubmitted">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/date-submitted"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='date-awarded']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-dateAwarded"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='date-awarded']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-dateAwarded">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/date-awarded"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

     <!--  TODO: Apply some logic surrounding conference start and end dates, should be combind into a single dateTime value -->
    <xsl:template match="api:field[@name='conference-start-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-conferenceStartDates"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='conference-start-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-conferenceStartates">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/conference-start-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='conference-finish-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-conferenceFinishDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='conference-finish-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-conferenceFinishDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/conference-finish-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>
    <xsl:template match="api:field[@name='finish-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-finishDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='finish-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-finishDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/finish-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>

    <xsl:template match="api:field[@name='awarded-date']" mode="objectReferences" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <core:dateTimeValue rdf:resource="{$baseURI}publication{$rid}-awardedDate"/>
    </xsl:template>
    
   <xsl:template match="api:field[@name='awarded-date']" mode="objectEntries" >
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
       <rdf:Description  rdf:about="{$baseURI}publication{$rid}-awardedDate">
         <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
         <rdf:type rdf:resource="http://vivoweb.org/ontology/core#DateTimeValue"/>
         <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/awarded-date"/>
         <xsl:apply-templates select="."  mode="dateTimeValue" />
       </rdf:Description>
    </xsl:template>
    
    
   <xsl:template match="api:field[@name='author-url']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:webpage rdf:resource="{$baseURI}publication{$rid}-authorWebpage"/>
    </xsl:template>

	<xsl:template match="api:field[@name='author-url']" mode="objectEntries">
		<xsl:variable name="rid" select="ancestor::api:object/@id"/>
		<rdf:Description rdf:about="{$baseURI}publication{$rid}-authorWebpage">
			<rdf:type rdf:resource="http://vivoweb.org/ontology/core#URLLink" />
			<rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing" />
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/author-url"/>
			<core:webpageOf rdf:resource="{$baseURI}publication{$rid}" />
			<core:linkURI rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">
				<xsl:value-of select="api:text" />
			</core:linkURI>
			<core:linkAnchorText rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">Author</core:linkAnchorText>
            <!--  add properties to enable smushing -->
            <svo:smush>author-url:<xsl:value-of select="api:text" /></svo:smush>
		</rdf:Description>
	</xsl:template>

   <xsl:template match="api:field[@name='publisher-url']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:webpage rdf:resource="{$baseURI}publication{$rid}-publisherWebpage"/>
    </xsl:template>

    <xsl:template match="api:field[@name='publisher-url']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-publisherWebpage">
            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#URLLink" />
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing" />
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/publisher-url"/>
            <core:webpageOf rdf:resource="{$baseURI}publication{$rid}" />
            <core:linkURI rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">
                <xsl:value-of select="api:text" />
            </core:linkURI>
            <core:linkAnchorText rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">Download Original</core:linkAnchorText>
            <!--  add properties to enable smushing -->
            <svo:smush>publisher-url:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>
    


    <!--  start of a group of templates that only outputs 1 object reference -->
    <xsl:template match="api:field[@name='presented-at']" mode="objectReferences" >
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <bibo:presentedAt rdf:resource="{$baseURI}publication{$rid}-presentedAt"/>
    </xsl:template>
    
    <xsl:template match="api:field[@name='conference-place']" mode="objectReferences" >
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <xsl:choose>
                <xsl:when test="ancestor::api:native/api:field[@name='presented-at']">
                </xsl:when>
                <xsl:otherwise>
                    <bibo:presentedAt rdf:resource="{$baseURI}publication{$rid}-presentedAt"/>
                </xsl:otherwise>
     </xsl:choose>
    </xsl:template>
    
    <xsl:template match="api:field[@name='name-of-conference']" mode="objectReferences" >
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <xsl:choose>
                <xsl:when test="ancestor::api:native/api:field[@name='presented-at']">
                </xsl:when>
                <xsl:when test="ancestor::api:native/api:field[@name='conference-place']">
                </xsl:when>
                <xsl:otherwise>
                    <bibo:presentedAt rdf:resource="{$baseURI}publication{$rid}-presentedAt"/>
                </xsl:otherwise>
     </xsl:choose>
    </xsl:template>
    <!--  end of group -->
    
    <xsl:template match="api:field[@name='conference-place' or @name='presented-at' or @name='name-of-conference']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id" />
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-presentedAt">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing" />
		    <rdf:type rdf:resource="http://purl.org/NET/c4dm/event.owl#Event"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Conference"/>
            <xsl:if test="ancestor::api:native/api:field[@name='location']">
                <core:hasGeographicLocation rdf:resource="{$baseURI}publication{$rid}-presentedAtLocation"/>
            </xsl:if>
            <bibo:presents rdf:resource="{$baseURI}publication{$rid}"/>
            
            <xsl:if test="ancestor::api:native/api:field[@name='conference-place']">
                <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/conference-place"/>
            </xsl:if>
            <xsl:if test="ancestor::api:native/api:field[@name='presented-at']">
                <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/presented-at"/>
            </xsl:if>
            <xsl:if test="ancestor::api:native/api:field[@name='name-of-conference']">
                <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/name-of-conference"/>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="ancestor::api:native/api:field[@name='presented-at']">
                            <rdfs:label><xsl:value-of select="ancestor::api:native/api:field[@name='presented-at']/api:text" /></rdfs:label>                                   
                </xsl:when>
	            <xsl:when test="ancestor::api:native/api:field[@name='name-of-conference'] and 
	                            ancestor::api:native/api:field[@name='conference-place']">
                            <rdfs:label>
                                <xsl:value-of select="ancestor::api:native/api:field[@name='name-of-conference']/api:text" />
                                <xsl:value-of select="ancestor::api:native/api:field[@name='conference-place']/api:text" />
                            </rdfs:label>                
	            </xsl:when>
                <xsl:when test="ancestor::api:native/api:field[@name='name-of-conference']">
                            <rdfs:label>
                                <xsl:value-of select="ancestor::api:native/api:field[@name='name-of-conference']/api:text" />
                                <xsl:value-of select="ancestor::api:native/api:field[@name='conference-place']/api:text" />
                            </rdfs:label>                
                </xsl:when>
                <xsl:when test="ancestor::api:native/api:field[@name='conference-place']">
                            <rdfs:label>
                                <xsl:value-of select="ancestor::api:native/api:field[@name='name-of-conference']/api:text" />
                                <xsl:value-of select="ancestor::api:native/api:field[@name='conference-place']/api:text" />
                            </rdfs:label>                
                </xsl:when>
            </xsl:choose>
            <!--  add properties to enable smushing -->
            <svo:smush>presentedat:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
        <xsl:if test="ancestor::api:native/api:field[@name='location']">
            <rdf:Description rdf:about="{$baseURI}publication{$rid}-presentedAtLocation">
               <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
               <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Location"/>
               <rdf:type rdf:resource="http://vivoweb.org/ontology/core#GeographicLocation"/>
               <core:geographicLocationOf rdf:resource="{$baseURI}publication{$rid}-presentedAt"/>
               <rdfs:label><xsl:value-of select="ancestor::api:native/api:field[@name='location']/api:text" /></rdfs:label>
	            <!--  add properties to enable smushing -->
	            <svo:smush>location:<xsl:value-of select="api:text" /></svo:smush>
            </rdf:Description>
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="api:field[@name='series']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:hasPublicationVenue rdf:resource="{$baseURI}publication{$rid}-series"/>
    </xsl:template>

    <xsl:template match="api:field[@name='series']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-series">
		    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Series"/>
		    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Collection"/>
		    <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/series"/>
		    <rdfs:label>
		                <xsl:value-of select="api:text" />
		    </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>series:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>
    <xsl:template match="api:field[@name='series-name']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:informationProductOf rdf:resource="{$baseURI}publication{$rid}-seriesName"/>
    </xsl:template>

    <xsl:template match="api:field[@name='series-name']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-seriesName">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Series"/>
            <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Collection"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/series-name"/>
            <rdfs:label>
                        <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>serise-name:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>


    <xsl:template match="api:field[@name='journal']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:hasPublicationVenue rdf:resource="{$baseURI}publication{$rid}-journal"/>
    </xsl:template>

    <xsl:template match="api:field[@name='journal']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-journal">
		    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Periodical"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Journal"/>
		    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#InformationResource"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/Collection"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/journal"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>journal:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>


    <xsl:template match="api:field[@name='commissioning-body']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:informationResourceSupportedBy rdf:resource="{$baseURI}publication{$rid}-commissioningBody"/>
    </xsl:template>

    <xsl:template match="api:field[@name='commissioning-body']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-commissioningBody">
		    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
		    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
		    <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/commissioning-body"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>organization:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>


    <xsl:template match="api:field[@name='supervisors']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:informationResourceSupportedBy rdf:resource="{$baseURI}publication{$rid}-supervisors"/>
    </xsl:template>

    <xsl:template match="api:field[@name='supervisors']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-supervisors">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person"/>
            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/supervisors"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>supervisors:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>
    
    

    <xsl:template match="api:field[@name='thesis-type']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <bibo:degree rdf:resource="{$baseURI}publication{$rid}-thesisType"/>
    </xsl:template>

    <xsl:template match="api:field[@name='thesis-type']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-thesisType">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://purl.org/ontology/bibo/ThesisDegree"/>
		    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#AcademicDegree"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/thesis-type"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>thesis-type:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="api:field[@name='credits']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <core:informationResourceSupportedBy rdf:resource="{$baseURI}publication{$rid}-credits"/>
    </xsl:template>

    <xsl:template match="api:field[@name='credits']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-credits">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/credits"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
        </rdf:Description>
    </xsl:template>



    <xsl:template match="api:field[@name='distributors']" mode="objectReferences">
     <xsl:variable name="rid" select="ancestor::api:object/@id" />
     <bibo:distributor rdf:resource="{$baseURI}publication{$rid}-distributors"/>
    </xsl:template>

    <xsl:template match="api:field[@name='distributors']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <rdf:Description rdf:about="{$baseURI}publication{$rid}-distributors">
            <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
            <rdf:type rdf:resource="http://www.symplectic.co.uk/vivo/distributors"/>
            <rdfs:label>
                  <xsl:value-of select="api:text" />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>organization:<xsl:value-of select="api:text" /></svo:smush>
        </rdf:Description>
    </xsl:template>
    
    
    <!--  BU specific -->
    <xsl:template
        match="api:organisation-defined-data[@field-name='Job Title']" mode="objectReferences">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <core:personInPosition rdf:resource="{$baseURI}{$rid}-jobTitle"/>
    </xsl:template>
    <xsl:template
        match="api:organisation-defined-data[@field-name='Job Title']" mode="objectEntries">
        <xsl:variable name="rid" select="ancestor::api:object/@id"/>
        <xsl:variable name="username" select="ancestor::api:object/@username"/>
        
        <rdf:Description rdf:about="{$baseURI}{$rid}-jobTitle">
		    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#Position"/>
		    <core:positionForPerson rdf:resource="{$baseURI}{$username}"/>
		    <core:positionInOrganization rdf:resource="{$baseURI}BournmouthUniversity"/>
            <rdfs:label>
                  <xsl:value-of select="." />
            </rdfs:label>
            <!--  add properties to enable smushing -->
            <svo:smush>jobtitle:<xsl:value-of select="." /></svo:smush>
        </rdf:Description>        
        <rdf:Description rdf:about="{$baseURI}BournmouthUniversity">
		    <rdf:type rdf:resource="http://vivoweb.org/ontology/core#University"/>
		    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#Thing"/>
		    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Organization"/>
		    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent"/>
		    <core:organizationForPosition rdf:resource="{$baseURI}{$rid}-jobTitle"/>
		    <rdfs:label>Bournmouth University</rdfs:label>
            <svo:smush>organization:Bournemouth University</svo:smush>
        </rdf:Description>
    </xsl:template>
    



</xsl:stylesheet>
