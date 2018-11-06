require 'securerandom'
require 'json'

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

Test_values =  {
 	"isbn": "",
 	"issn": "0022-1111",
 	"issue": "59",
  "title": "python json",
 	#"title": "First host records for the rogadine genera Rogasodes Chen & He and Canalirogas van Achterberg & Chen (Hymenoptera: Braconidae) with description of a new species and survey of mummy types within Rogadinae s. str",
 	"abstract": "The parasitic wasp genus Rogasodes is recorded for the first time outside mainland China, based on a new species, R. scytaloptericola Quicke and Shaw sp. nov., from Java. Rearing data and host remains associated with the type specimen show that it is a parasitoid of the palm-feeding drepanid moth, Scytalopteryx elongata (Snellen). Canalirogas sp. aff. balgooyi van Achterberg and Chen is recorded from an unidentified lymantriid on clove trees in Indonesia (Sumatra) and illustrated. Both of these are the first host records for the genera. Rogas spilonotus Cameron is transferred to Canalirogas. A survey of mummy sclerotization and adult emergence holes in the subfamily Rogadinae sensu stricto is presented. The data suggest an early shift to a posterior emergence position, with a strictly dorsal position being largely characteristic of the common genus Aleiodes. Only Aleiodes and a few apparently closely related taxa, including Hemigyroneuron, typically form heavily sclerotized mummies. ",
 	"funder_1": "",
 	"funder_2": "",
 	"volume_1": "39",
 	"keyword": "museums, library",
 	"keyword_2": "",
 	"type": "Article",
 	"book_title": "",
 	"publisher_1": "Taylor & Francis",
 	"official_link": "http://www.tandf.co.uk",
 	"project_name": "",
 	"journal_title": "Journal of Natural History",
 	"related_url_1": "",
 	"related_url_2": "",
 	"resource_type": "Article default Journal article",
 	"series_name_1": "",
 	"date_published": "2018",
 	"rights_holder_1": "Taylor & Francis",
 	"add_info": "",
 	"place_of_publication_1": "",
 #	"editor": "[{\"editor_name_type\": \"Personal\", \"editor_position\": \"0\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"1\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"2\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"3\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"4\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"5\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"6\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"7\"}, {\"editor_name_type\": \"Personal\", \"editor_position\": \"8\"}]",
 	"creator": "[{\"creator_name_type\": \"Personal\", \"creator_family_name\": \"Quicke\", \"creator_given_name\": \"D. L. J.\", \"creator_position\": \"0\"}, {\"creator_name_type\": \"Personal\", \"creator_family_name\": \"Shaw\", \"creator_given_name\": \"Mark R\", \"creator_position\": \"1\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"2\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"3\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"4\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"5\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"6\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"7\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"8\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"9\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"10\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"11\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"12\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"13\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"14\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"15\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"16\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"17\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"18\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"19\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"20\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"21\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"22\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"23\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"24\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"25\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"26\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"27\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"28\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"29\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"30\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"31\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"32\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"33\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"34\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"35\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"36\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"37\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"38\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"39\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"40\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"41\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"42\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"43\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"44\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"45\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"46\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"47\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"48\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"49\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"50\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"51\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"52\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"53\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"54\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"55\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"56\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"57\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"58\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"59\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"60\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"61\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"62\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"63\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"64\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"65\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"66\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"67\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"68\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"69\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"70\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"71\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"72\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"73\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"74\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"75\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"76\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"77\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"78\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"79\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"80\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"81\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"82\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"83\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"84\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"85\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"86\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"87\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"88\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"89\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"90\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"91\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"92\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"93\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"94\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"95\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"96\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"97\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"98\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"99\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"100\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"101\"}, {\"creator_name_type\": \"Personal\", \"creator_position\": \"102\"}]",
 	"contributor": "[{\"contributor_name_type\": \"Personal\", \"contributor_position\": \"0\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"1\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"2\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"3\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"4\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"5\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"6\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"7\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"8\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"9\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"10\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"11\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"12\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"13\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"14\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"15\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"16\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"17\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"18\"}, {\"contributor_name_type\": \"Personal\", \"contributor_position\": \"19\"}]",
 	"related_identifier": "",
  "alternate_identifier": "[{\"alternate_identifier_type\": \"Digital Asset Register Id\", \"alternate_identifier_id\": \"DAR00147\"}]",
 	#"file": "",
  "file": "2f52f908ce3841e68984f40a3210f372.jpg",
 	 "id": "26912d9a-f1a9-43d2-abed-f61f82d48703",
   "id": "25011033-62df-434b-a45d-9d3d95dbfc8a",
 	#"domain": "repo-staging.ubiquity.press",
 	#"tenant": "test"
  "domain": "localhost",
  "tenant": "library"
 }
