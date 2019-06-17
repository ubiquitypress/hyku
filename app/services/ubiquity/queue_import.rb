require 'securerandom'
require 'json'

#to run from rails console
#first call any of the constants below and assign it to a variable
# k = Sample
#Next call the importer and pass it the variable above
# QueueImport.upload(k)
#
class QueueImport

  def self.upload(values)
    redis = Redis.current

     msg = { "class" => 'UbiquityJsonImporterJob',
             "queue" => 'ubiquity_json_importer',
             "args" => [values],
            'retry' => true,
            'jid' => SecureRandom.hex(12),
            'created_at' => Time.now.to_f,
            'enqueued_at' => Time.now.to_f
          }
     #To get the queue to show up under the "Queues" tab and the "Enqueued" count to be correct, you must also add the queue name to the queues set
     redis.sadd("queues", "ubiquity_json_importer")
     redis.lpush("queue:ubiquity_json_importer", JSON.dump(msg) )
  end

end

New_json =   {
 	"doi": "https://doi.org/10.22021/LODBNB1",
 	"isbn": "",
 	"issn": "",
 	"eissn": "",
 	"issue": "",
 	"title": "editable upload.",
 	"edition": "",
 	"abstract": "This dataset includes metadata for books published or distributed in the UK since 1950.",
 	"funder": "",
 	"volume": "",
 	"keyword": "data-bl7||metadata||BNB||British National Bibliography||linked open data||N-Triples||NT||RDF/XML||books",
 	"license": "http://creativecommons.org/publicdomain/zero/1.0/",
 	"version": "",
 	"type": "Dataset",
 	"book_title": "",
 	"language": "English",
 	"pagination": "",
 	"publisher": "British Library",
 	"official_link": "https://doi.org/10.22021/LODBNB1",
 	"date_accepted": "",
 	"institution": "British Library",
 	"journal_title": "",
 	"refereed": "",
 	"related_url": "https://doi.org/10.22021/BSLDNTZ201803",
 	"resource_type": "Dataset default Dataset",
 	"series_name": "",
 	"date_published": "2018",
 	"date_submitted": "",
 	"rights_holder": "",
 	"article_num": "",
 	"media": "",
 	"rights_statement": "",
 	"related_exhibition": "",
 	"org_unit": "British Library Labs",
 	"add_info": "Latest release: The two files represent different serializations for the same dataset. DOI https://doi.org/10.22021/BBLDNTZ201803 - The 1,311,699 KB N-Triples .zip file (created using 7-Zip) contains 39 N-Triples files and 1 PDF file for Terms & Conditions. The data consists of 132,186,988 triples, representing 3,648,709 books. DOI https://doi.org/10.22021/BBLDRDFZ201803 - The 1,369,769 KB RDF/XML .zip file (created using 7-Zip) contains 75 RDF/XML files and 1 PDF for Terms & Conditions. Previous versions: The DOIs listed below identify previous versions of the dataset. These versions only differ in their temporal coverage, unless stated otherwise. Previous versions are available on request. DOI https://doi.org/10.22021/BBLDNTZ201802 DOI https://doi.org/10.22021/BBLDRDFZ201802 DOI https://doi.org/10.22021/BBLDNTZ201801 DOI https://doi.org/10.22021/BBLDRDFZ201801 DOI https://doi.org/10.22021/BBLDNTZ201712 DOI https://doi.org/10.22021/BBLDRDFZ201712 DOI https://doi.org/10.22021/BBLDNTZ201711 DOI https://doi.org/10.22021/BBLDRDFZ201711 DOI https://doi.org/10.22021/BBLDNTZ201710 DOI https://doi.org/10.22021/BBLDRDFZ201710 DOI https://doi.org/10.22021/BBLDNTZ201709 DOI https://doi.org/10.22021/BBLDRDFZ201709 DOI https://doi.org/10.22021/BBLDNTZ201708 DOI https://doi.org/10.22021/BBLDRDFZ201708 DOI https://doi.org/10.22021/BBLDNTZ201707 DOI https://doi.org/10.22021/BBLDRDFZ201707 DOI https://doi.org/10.22021/BBLDNTZ201706 DOI https://doi.org/10.22021/BBLDRDFZ201706 DOI https://doi.org/10.22021/BBLDNTZ201705 DOI https://doi.org/10.22021/BBLDRDFZ201705 DOI https://doi.org/10.22021/BBLDNTZ201704 DOI https://doi.org/10.22021/BBLDRDFZ201704 DOI https://doi.org/10.22021/BBLDNTZ201703 DOI https://doi.org/10.22021/BBLDRDFZ201703 DOI https://doi.org/10.22021/BBLDNTZ201702 DOI https://doi.org/10.22021/BBLDRDFZ201702 DOI https://doi.org/10.22021/BBLDNTZ201701 DOI https://doi.org/10.22021/BBLDRDFZ201701 DOI https://doi.org/10.22021/BBLDNTZ201612 DOI https://doi.org/10.22021/BBLDRDFZ201612 DOI https://doi.org/10.22021/BBLDNTZ201611 DOI https://doi.org/10.22021/BBLDRDFZ201611 DOI https://doi.org/10.22021/BBLDNTZ201610 DOI https://doi.org/10.22021/BBLDRDFZ201610 DOI https://doi.org/10.22021/BBLDNTZ201609 DOI https://doi.org/10.22021/BBLDRDFZ201609",
 	"place_of_publication": "London, UK|| Newyork, USA",
 	"related_exhibition_date": "",
 	"fndr_project_ref": "",
 	"editor": "",
 	"creator": [{
 		"creator_name_type": "Organisational",
 		"creator_isni": "0000 0001 2308 1542",
 		"creator_organization_name": "British Library",
 		"creator_position": "0"
 	}, {
 		"creator_name_type": "Personal",
 		"creator_isni": "0000 0004 6880 3125",
 		"creator_family_name": "Deliot",
 		"creator_given_name": "Corine",
 		"creator_position": "1"
 	}],
 	"contributor": [{
 		"contributor_name_type": "Personal",
 		"contributor_isni": "0000 0004 6880 3125",
 		"contributor_family_name": "Deliot",
 		"contributor_given_name": "Corine",
 		"contributor_type": "DataCurator",
 		"contributor_position": "0"
 	}],
 	"related_identifier": "",
 	"alternate_identifier": "",
 	#"file": "589dce2b-3d88-4bac-953b-bdf710c6b6b6.png||https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Yellow-spotted_Rock_Hyrax.jpg/1200px-Yellow-spotted_Rock_Hyrax.jpg||https://media.mnn.com/assets/images/2015/11/elephants-rock-hyrax.jpg.1000x0_q80_crop-smart.jpg",
  "file": "https://www.incimages.com/uploaded_files/image/970x450/getty_883231284_200013331818843182490_335833.jpg",
  "id": "80706a8e-882c-45d8-ad5d-ae898b98531f",
  "visibility": "open",
 	"domain": "localhost",
 	"tenant": "library",
  "file_only_import": 'false'
 }

 Sample = {"doi":"https://doi.org/10.21250/sherlocknet1","isbn":"123","issn":"********","eissn":"********","issue":"issue 1","title":"ability to set visibility via importer","funder":"Funder name 1||Funder name 2","volume":"volume 1","edition":"edition 1","keyword":"all-fields-import||microsoft||books||digitised||images||sherlocknet||Flickr||tags||tagging||keyword10||keyword11||keyword12","license":"https://opensource.org/licenses/MIT||https://creativecommons.org/licenses/by/4.0/","version":"v1||v2","abstract":"Donec feugiat magna ac commodo pharetra. Pellentesque aliquam vel ex nec eleifend. Vestibulum vulputate aliquam lectus et porttitor. Fusce fringilla purus ut massa consectetur iaculis. Curabitur efficitur ultricies aliquet. Ut ut semper sem. Morbi sed ipsum hendrerit, interdum nisl vitae, hendrerit tortor. Sed ornare erat eros, nec accumsan turpis gravida sed.","language":"English||French","publisher":"British Library","type":"Dataset","book_title":"book title","pagination":"1-5","event_title":"Event title 1||Event tittle 2","institution":"British Library||National Museums Scotland","related_url":"https://github.com/ludazhao/SherlockNet||https://google.com||https://www.ubiquitypress.com||https://bbc.co.uk","series_name":"series 1","official_link":"https://doi.org/10.21250/sherlocknet1","project_name":"Project name","date_accepted":"2016-02-02","journal_title":"journal title","refereed":"Not Peer-reviewed","resource_type":"Dataset default Dataset","rights_holder":"British Library Board||Another rights holder","article_num":"123","date_published":"2017-02-02","date_submitted":"2015-02-02","media":"media","rights_statement":"http://rightsstatements.org/vocab/InC/1.0/","related_exhibition":"Exhibition name 1||Exhibition name 2","organisational_unit":"British Library Labs||Testing Labs","place_of_publication":"London, UK||Cair Paravel, Narnia","add_info":"Nunc elementum tincidunt mauris, quis cursus diam dictum fringilla. Etiam luctus nibh ac mauris egestas placerat sed non orci. Praesent tincidunt tortor orci, id ultrices enim vestibulum gravida.","related_exhibition_date":"2018-02-02||2019-02-02","fndr_project_ref":"123||456","editor":[{"editor_isni":"123","editor_orcid":"123","editor_given_name":"John","editor_name_type":"Personal","editor_family_name":"Smith","editor_position":"0"},{"editor_isni":"456","editor_orcid":"456","editor_given_name":"Cardinal","editor_name_type":"Personal","editor_family_name":"Wolsey","editor_position":"1"}],"creator":[{"creator_name_type":"Organisational","creator_isni":"0000 0001 2308 1542","creator_organization_name":"British Library","creator_position":"0"},{"creator_name_type":"Personal","creator_family_name":"Zhao","creator_given_name":"Luda","creator_position":"1"},{"creator_name_type":"Personal","creator_family_name":"Do","creator_given_name":"Brian","creator_position":"2"},{"creator_name_type":"Personal","creator_family_name":"Wang","creator_given_name":"Karen","creator_position":"3"}],"contributor":[{"contributor_name_type":"Personal","contributor_family_name":"Edwards","contributor_given_name":"Adrian","contributor_type":"Data Curator","contributor_position":"0"},{"contributor_name_type":"Personal","contributor_isni":"123","contributor_orcid":"123","contributor_family_name":"Bloggs","contributor_given_name":"Joe","contributor_type":"Data Curator","contributor_position":"1"},{"contributor_name_type":"Personal","contributor_orcid":"123","contributor_family_name":"Doe","contributor_given_name":"Jane","contributor_type":"Data Curator","contributor_position":"2"}],"related_identifier":[{"related_identifier":"10.5334/sta.at","related_identifier_type":"DOI","relation_type":"IsCitedBy","related_identifier_position":"0"}],"alternate_identifier":[{"alternate_identifier":"1","alternate_identifier_type":"made up identifier","alternate_identifier_position":"0"},{"alternate_identifier":"2","alternate_identifier_type":"another invented identifier","alternate_identifier_position":"1"}],"file":'/data/tmp/uploads/7cab1d1e-e15c-43bb-9733-55fb8d8acf2a/hyrax/uploaded_file/file/60/schumpeter.jpg',"id":"7033aaf5-7bfe-4da6-9d2f-74b3704c51b1","domain":"localhost","tenant":"library","visibility":"open"}

Sample_delete = {:id => "7033aaf5-7bfe-4da6-9d2f-74b3704c51b1", :abstract => "", :domain => "localhost",
  :title => "via importer", :tenant=> "library", :type => "Dataset"}

Nms =  {
                "doi": "",
                "isbn": "",
                "issn": "0013-8916",
                "issue": "1",
                "title": "Moth populations and bad weather – four speculative observations",
                "funder": "",
                "volume": "125",
                "keyword": "a||b||c",
                "abstract": "",
                "publisher": "",
                "type": "Article",
                "book_title": "",
                "pagination": "33-37",
                "visibility": "open",
                "event_title": "",
                "institution": "National Museums Scotland",
                "related_url": "",
                "series_name": "",
                "official_link": "http://www.entrecord.com/contents1301.htm",
                "project_name": "",
                "journal_title": "Entomologist's Record and Journal of Variation",
                "refereed": "Peer-reviewed",
                "resource_type": "Article default Journal article",
                "rights_holder": "",
                "date_published": "2013",
                "date_submitted": "",
                "event_location": "",
                "related_exhibition": "",
                "organisational_unit": "Natural Sciences",
                "place_of_publication": "",
                "add_info": "",
                "library_of_congress_classification": "QL",
                "editor": "",
                "creator": [
                    {
                        "creator_name_type": "Personal",
                        "creator_orcid": "https://orcid.org/0000-0002-6651-8801",
                        "creator_family_name": "Shaw",
                        "creator_given_name": "Mark R",
                        "creator_institutional_relationship": [
                            "Staff member",
                            "Research associate"
                        ],
                        "creator_position": "0"
                    }
                ],
                "contributor": "",
                "related_identifier": "",
                "alternate_identifier": "",
                "file": "",
                "id": "d76279db-c5cb-46d1-a964-a49b615ff131",
                "domain": "localhost",
                "tenant": "library"
            }


Sandbox = {
                "doi": "https://doi.org/10.21250/aascc21",
                "isbn": "",
                "issn": "",
                "eissn": "",
                "issue": "",
                "title": "AAS Card Catalogues: Sinhalese",
                "funder": "",
                "volume": "",
                "edition": "",
                "keyword": "AAS||card||catalogue||PDF||pdf||Sinhalese",
                "license": "https://creativecommons.org/publicdomain/mark/1.0/",
                "version": "",
                "abstract": "This dataset contains digitised microfilms of Sinhalese card catalogues.",
                "language": "Sinhalese",
                "publisher": "British Library",
                "type": "Dataset",
                "book_title": "",
                "pagination": "",
                "event_title": "",
                "institution": "British Library",
                "related_url": "",
                "series_name": "",
                "official_link": "https://doi.org/10.21250/aascc21",
                "project_name": "Asian and African Collections: Card Catalogues",
                "date_accepted": "",
                "journal_title": "",
                "refereed": "",
                "resource_type": "Dataset default Dataset",
                "rights_holder": "",
                "article_num": "",
                "date_published": "2017",
                "date_submitted": "",
                "media": "",
                "rights_statement": "",
                "related_exhibition": "",
                "organisational_unit": "Asian and African Studies",
                "place_of_publication": "London, UK",
                "add_info": "The 6.81 GB ZIP file (created using 7-Zip) contains 104 PDF documents.",
                "related_exhibition_date": "",
                "fndr_project_ref": "",
                "editor": "",
                "creator": [
                    {
                        "creator_name_type": "Organisational",
                        "creator_isni": "0000 0001 2308 1542",
                        "creator_organization_name": "British Library",
                        "creator_position": "0"
                    }
                ],
                "contributor": [
                    {
                        "contributor_name_type": "Personal",
                        "contributor_isni": "0000 0004 4772 9640",
                        "contributor_orcid": "0000-0002-7202-4875",
                        "contributor_family_name": "Sobers-Khan",
                        "contributor_given_name": "Nur",
                        "contributor_type": "Curator",
                        "contributor_position": "0"
                    }
                ],
                "related_identifier": "",
                "alternate_identifier": [
                    {
                        "alternate_identifier": "DAR00554",
                        "alternate_identifier_type": "Digital Asset Register ID",
                        "alternate_identifier_position": "0"
                    }
                ],
                "file": "",
                "id": "8525090e-5ed1-4f11-a378-5c420e04f276",
                "domain": "localhost",
                "tenant": "library"
            }


Stuff = {"doi":"https://doi.org/10.21250/sherlocknet1","isbn":"123","issn":"********","eissn":"********","issue":"issue 1","title":"doing stuff","funder":"Funder name 1||Funder name 2","volume":"volume 1","edition":"edition 1","keyword":"all-fields-import||microsoft||books||digitised||images||sherlocknet||Flickr||tags||tagging||keyword10||keyword11||keyword12","license":"https://opensource.org/licenses/MIT||https://creativecommons.org/licenses/by/4.0/","version":"v1||v2","abstract":"Donec feugiat magna ac commodo pharetra. Pellentesque aliquam vel ex nec eleifend. Vestibulum vulputate aliquam lectus et porttitor. Fusce fringilla purus ut massa consectetur iaculis. Curabitur efficitur ultricies aliquet. Ut ut semper sem. Morbi sed ipsum hendrerit, interdum nisl vitae, hendrerit tortor. Sed ornare erat eros, nec accumsan turpis gravida sed.","language":"English||French","publisher":"British Library","type":"Dataset","book_title":"book title","pagination":"1-5","event_title":"Event title 1||Event tittle 2","institution":"British Library||National Museums Scotland","related_url":"https://github.com/ludazhao/SherlockNet||https://google.com||https://www.ubiquitypress.com||https://bbc.co.uk","series_name":"series 1","official_link":"https://doi.org/10.21250/sherlocknet1","project_name":"Project name","date_accepted":"2016-02-02","journal_title":"journal title","refereed":"Not Peer-reviewed","resource_type":"Dataset default Dataset","rights_holder":"British Library Board||Another rights holder","article_num":"123","date_published":"2017-02-02","date_submitted":"2015-02-02","media":"media","rights_statement":"http://rightsstatements.org/vocab/InC/1.0/","related_exhibition":"Exhibition name 1||Exhibition name 2","organisational_unit":"British Library Labs||Testing Labs","place_of_publication":"London, UK||Cair Paravel, Narnia","add_info":"Nunc elementum tincidunt mauris, quis cursus diam dictum fringilla. Etiam luctus nibh ac mauris egestas placerat sed non orci. Praesent tincidunt tortor orci, id ultrices enim vestibulum gravida.","related_exhibition_date":"2018-02-02||2019-02-02","fndr_project_ref":"123||456","editor":[{"editor_isni":"123","editor_orcid":"123","editor_given_name":"John","editor_name_type":"Personal","editor_family_name":"Smith","editor_position":"0"},{"editor_isni":"456","editor_orcid":"456","editor_given_name":"Cardinal","editor_name_type":"Personal","editor_family_name":"Wolsey","editor_position":"1"}],"creator":[{"creator_name_type":"Organisational","creator_isni":"0000 0001 2308 1542","creator_organization_name":"British Library","creator_position":"0"},{"creator_name_type":"Personal","creator_family_name":"Zhao","creator_given_name":"Luda","creator_position":"1"},{"creator_name_type":"Personal","creator_family_name":"Do","creator_given_name":"Brian","creator_position":"2"},{"creator_name_type":"Personal","creator_family_name":"Wang","creator_given_name":"Karen","creator_position":"3"}],"contributor":[{"contributor_name_type":"Personal","contributor_family_name":"Edwards","contributor_given_name":"Adrian","contributor_type":"Data Curator","contributor_position":"0"},{"contributor_name_type":"Personal","contributor_isni":"123","contributor_orcid":"123","contributor_family_name":"Bloggs","contributor_given_name":"Joe","contributor_type":"Data Curator","contributor_position":"1"},{"contributor_name_type":"Personal","contributor_orcid":"123","contributor_family_name":"Doe","contributor_given_name":"Jane","contributor_type":"Data Curator","contributor_position":"2"}],"related_identifier":[{"related_identifier":"10.5334/sta.at","related_identifier_type":"DOI","relation_type":"IsCitedBy","related_identifier_position":"0"}],"alternate_identifier":[{"alternate_identifier":"1","alternate_identifier_type":"made up identifier","alternate_identifier_position":"0"},{"alternate_identifier":"2","alternate_identifier_type":"another invented identifier","alternate_identifier_position":"1"}],"file":'/data/tmp/uploads/7cab1d1e-e15c-43bb-9733-55fb8d8acf2a/hyrax/uploaded_file/file/60/schumpeter.jpg',"id":"7133aaf5-7bfe-4da6-9d2f-74b3704c61z1","domain":"localhost","tenant":"library","visibility":"open"}
