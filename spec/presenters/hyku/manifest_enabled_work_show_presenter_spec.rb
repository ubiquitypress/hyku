RSpec.describe Hyku::ManifestEnabledWorkShowPresenter do
  let(:work) { FactoryGirl.create(:work_with_one_file) }
  let(:document) { work.to_solr }
  let(:solr_document) { SolrDocument.new(document) }
  let(:request) { double(base_url: 'http://test.host', host: 'http://test.host') }
  let(:ability) { nil }
  let(:presenter) { described_class.new(solr_document, ability, request) }

  describe "#manifest_url" do
    subject { presenter.manifest_url }

    let(:document) { { "has_model_ssim" => ['GenericWork'], 'id' => '99' } }

    it { is_expected.to eq 'http://test.host/concern/generic_works/99/manifest' }
  end

  describe "representative_presenter" do
    subject do
      presenter.representative_presenter
    end

    before do
      work.representative_id = work.file_sets.first.id
    end
    it "returns a presenter" do
      expect(subject).to be_kind_of Hyku::FileSetPresenter
    end
  end

  describe "#sequence rendering" do
    subject do
      presenter.sequence_rendering
    end

    before do
      Hydra::Works::AddFileToFileSet.call(work.file_sets.first,
                                          fixture_file('images/world.png'), :original_file)
    end

    it "returns a hash containing the rendering information" do
      work.rendering_ids = [work.file_sets.first.id]
      expect(subject).to be_an Array
    end
  end

  describe "#manifest metadata" do
    subject do
      presenter.manifest_metadata
    end

    before do
      work.title = ['Test title', 'Another test title']
    end

    it "returns an array of metadata values" do
      expect(subject[0]['label']).to eq('Title')
      expect(subject[0]['value']).to include('Test title', 'Another test title')
    end
  end

  context "when the work has valid doi and isbns" do
    # the values are set in generic_works factory
    describe "#doi_from_identifier" do
      it "extracts the DOI from the identifiers" do
        expect(presenter.doi_from_identifier).to eq('10.1038/nphys1170')
      end
    end

    describe "#isbns" do
      it "extracts ISBNs from the identifiers" do
        expect(presenter.isbns)
          .to match_array(%w[978-83-7659-303-6 978-3-540-49698-4 9790879392788
                             3-921099-34-X 3-540-49698-x 0-19-852663-6])
      end
    end
  end

  context "when the identifier is nil" do
    let(:document) do
      { "identifier_tesim" => nil }
    end

    describe "#doi_from_identifier" do
      it "is nil" do
        expect(presenter.doi_from_identifier).to be_nil
      end
    end

    describe "#isbns" do
      it "is nil" do
        expect(presenter.isbns).to be_nil
      end
    end
  end

  context "when the work has a doi only" do
    let(:document) do
      { "identifier_tesim" => ['10.1038/nphys1170'] }
    end

    describe "#isbns" do
      it "is empty" do
        expect(presenter.isbns).to be_empty
      end
    end
  end

  context "when the work has isbn(s) only" do
    let(:document) do
      { "identifier_tesim" => ['ISBN:978-83-7659-303-6'] }
    end

    describe "#doi_from_identifier" do
      it "is empty" do
        expect(presenter.doi_from_identifier).to be_empty
      end
    end
  end

  context "when the work's identifiers are not valid doi or isbns" do
    # FOR CONSIDERATION: validate format when a user adds an identifier?
    let(:document) do
      { "identifier_tesim" => %w[3207/2959859860 svnklvw24 0470841559.ch1] }
    end

    describe "#doi_from_identifier" do
      it "is empty" do
        expect(presenter.doi_from_identifier).to be_empty
      end
    end

    describe "#isbns" do
      it "is empty" do
        expect(presenter.isbns).to be_empty
      end
    end
  end

  describe "#model" do
    let(:dataset) { FactoryGirl.build(:dataset) }
    let(:solr_document) { SolrDocument.new(dataset.to_solr) }

    it "returns the model name" do
      expect(presenter.model).to eq("Dataset")
    end
  end

  describe "#no_associated_file?" do
    it "returns false if a work has a file set" do
      expect(presenter.no_associated_file?).to be false
    end

    it "returns true if a work does not have a file set" do
      work_with_no_file = FactoryGirl.create(:work)
      solr_document2 = SolrDocument.new(work_with_no_file.to_solr)
      presenter2 = described_class.new(solr_document2, nil)
      expect(presenter2.no_associated_file?).to be true
    end
  end

  describe "#edit_access" do
    it "returns the user who can edit the work" do
      editor = solr_document['edit_access_person_ssim']
      expect(presenter.edit_access).to eq(editor)
    end
  end
end