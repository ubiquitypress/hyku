require 'rails_helper'
require 'spec_helper'

RSpec.describe API::V1::SearchController, type: :request, clean: true do
  let!(:user) { create(:user, :confirmed) }
  let!(:account) { create(:account) }

  before do
    WebMock.disable!
  end

  after do
    WebMock.enable!
  end

  describe "/search" do
    let(:json_response) { JSON.parse(response.body) }
    let(:search_q) { '' }
    let(:search_f) { '' }

    context 'when repository is empty' do
      it 'returns error' do
        get "/api/v1/tenant/#{account.id}/search"
        expect(response.status).to eq(200)
        expect(json_response).to include('status' => 404,
                                         'code' => 'not_found',
                                         'message' => "No record found for query_term: #{search_q} and filters containing #{search_f}")
      end
    end

    context 'when repository has content' do
      let!(:collection) { create(:collection, visibility: 'open') }
      let!(:work) { create(:work, visibility: 'open') }

      it 'returns collection and work results' do
        get "/api/v1/tenant/#{account.id}/search"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 2
        expect(json_response['items']).to include(hash_including('uuid' => collection.id),
                                                 hash_including('uuid' => work.id))
        expect(json_response['facet_counts']).to be_present
      end
    end

    context 'when not logged in' do
      let!(:work) { create(:work, visibility: 'restricted') }

      it 'does not return restricted results' do
        get "/api/v1/tenant/#{account.id}/search"
        expect(response.status).to eq(200)
        expect(json_response).to include('status' => 404,
                                         'code' => 'not_found',
                                         'message' => "No record found for query_term: #{search_q} and filters containing #{search_f}")
      end
    end

    context 'when logged in' do
      let!(:work) { create(:work, visibility: 'restricted') }
      let!(:user) { create(:admin, :confirmed) }

      before do
        post api_v1_user_login_url(tenant_id: account.id),  params: {
          email: user.email,
          password: user.password,
          expire: 2
        }
      end

      it 'returns restricted results' do
        get "/api/v1/tenant/#{account.id}/search", headers: { "Cookie" => response['Set-Cookie'] }
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq work.id
        expect(json_response['facet_counts']).to be_present
      end
    end

    context 'with q' do
      let!(:work1) { create(:work, visibility: 'open', title: ['Cat']) }
      let!(:work2) { create(:work, visibility: 'open', title: ['Dog']) }

      it 'filters work results' do
        get "/api/v1/tenant/#{account.id}/search?q=cat"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq work1.id
        expect(json_response['facet_counts']).to be_present
        expect(response).to render_template('api/v1/work/_work')
      end
    end

    context 'with f' do
      let!(:collection) { create(:collection, visibility: 'open') }
      let!(:work) { create(:work, visibility: 'open') }

      it 'filters work results' do
        get "/api/v1/tenant/#{account.id}/search?f[human_readable_type_sim][]=Work"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq work.id
        expect(json_response['facet_counts']).to be_present
        expect(response).to render_template('api/v1/work/_work')
      end

      it 'filters collection results' do
        get "/api/v1/tenant/#{account.id}/search?f[human_readable_type_sim][]=Collection"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 1
        expect(json_response['items'][0]['uuid']).to eq collection.id
        expect(json_response['facet_counts']).to be_present
        expect(response).to render_template('api/v1/collection/_collection')
      end
    end

    context 'with sort' do
      let!(:work1) { create(:work, visibility: 'open', date_published: '1996') }
      let!(:work2) { create(:work, visibility: 'open', date_published: '1990') }
      let(:sort) { 'date_published_si asc' }

      it 'sorts results' do
        get "/api/v1/tenant/#{account.id}/search?sort=#{sort}"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 2
        expect(json_response['items'][0]['uuid']).to eq work2.id
        expect(json_response['items'][1]['uuid']).to eq work1.id
        expect(json_response['facet_counts']).to be_present
      end
    end

    context 'with per_page' do
      let!(:work1) { create(:work, visibility: 'open', date_published: '1996') }
      let!(:work2) { create(:work, visibility: 'open', date_published: '1990') }
      let(:per_page) { 1 }
      let(:sort) { 'date_published_si desc' }

      it 'limits the number of results' do
        get "/api/v1/tenant/#{account.id}/search?per_page=#{per_page}&sort=#{sort}"
        expect(response.status).to eq(200)
        expect(json_response['total']).to eq 2
        expect(json_response['items'].size).to eq 1
        expect(json_response['items'][0]['uuid']).to eq work1.id
        expect(json_response['facet_counts']).to be_present
      end

      context 'with page' do
        let(:page) { 2 }
  
        it 'limits the number of results and offsets to page' do
          get "/api/v1/tenant/#{account.id}/search?per_page=#{per_page}&page=#{page}&sort=#{sort}"
          expect(response.status).to eq(200)
          expect(json_response['total']).to eq 2
          expect(json_response['items'].size).to eq 1
          expect(json_response['items'][0]['uuid']).to eq work2.id
          expect(json_response['facet_counts']).to be_present
        end
      end
    end
  end

  describe "/search/facet/:id" do
    let(:facet_results) { JSON.parse(response.body).reduce(&:merge) }
    let(:json_response) { JSON.parse(response.body) }

    context 'all facets' do
      let!(:work) { create(:work, visibility: 'open', keyword: ['test'], language: ['English']) }
      let(:id) { 'all' }

      it 'returns facet information' do
        get "/api/v1/tenant/#{account.id}/search/facet/#{id}"
        expect(response.status).to eq(200)
        expect(facet_results).to include('keyword_sim' => { "test" => 1},
                                         'language_sim' => { "English" => 1 },
                                         'file_availability_sim' => { "File not available" => 1 },
                                         'resource_type_sim' => {},
                                         'creator_search_sim' => {},
                                         'collection_names_sim' => {},
                                         'member_of_collections_ssim' => {},
                                         'institution_sim' => {})
      end

      context 'with q' do
        let!(:work1) { create(:work, visibility: 'open', keyword: ['Cat'], language: ["English"]) }
        let!(:work2) { create(:work, visibility: 'open', keyword: ['Dog'], language: ["French"]) }
        let(:q) { 'cat' }

        it 'returns facet information' do
          get "/api/v1/tenant/#{account.id}/search/facet/#{id}?q=#{q}"
          expect(response.status).to eq(200)
          expect(facet_results).to include('keyword_sim' => { "Cat" => 1},
                                           'language_sim' => { "English" => 1 },
                                           'file_availability_sim' => { "File not available" => 1 },
                                           'resource_type_sim' => {},
                                           'creator_search_sim' => {},
                                           'collection_names_sim' => {},
                                           'member_of_collections_ssim' => {},
                                           'institution_sim' => {})
        end
      end

      context 'with f' do
        let!(:work1) { create(:work, visibility: 'open', keyword: ['Cat'], language: ["English"]) }
        let!(:work2) { create(:work, visibility: 'open', keyword: ['Dog'], language: ["French"]) }
        let(:f) { 'Cat' }

        it 'filters results' do
          get "/api/v1/tenant/#{account.id}/search/facet/#{id}?f[keyword_sim][]=#{f}"
          expect(response.status).to eq(200)
          expect(facet_results).to include('keyword_sim' => { "Cat" => 1},
                                           'language_sim' => { "English" => 1 },
                                           'file_availability_sim' => { "File not available" => 1 },
                                           'resource_type_sim' => {},
                                           'creator_search_sim' => {},
                                           'collection_names_sim' => {},
                                           'member_of_collections_ssim' => {},
                                           'institution_sim' => {})
        end
      end
    end

    context 'single facet' do
      let!(:work1) { create(:work, visibility: 'open', keyword: ['Cat']) }
      let(:id) { 'file_availability_sim' }

      it 'returns facet information' do
        get "/api/v1/tenant/#{account.id}/search/facet/#{id}"
        expect(response.status).to eq(200)
        expect(json_response).to eq({ "File not available" => 1 })
      end

      context 'with q' do
        let!(:work2) { create(:work, visibility: 'open', keyword: ['Dog']) }
        let(:id) { 'keyword_sim' }
        let(:q) { 'cat' }
  
        it 'filters work results' do
          get "/api/v1/tenant/#{account.id}/search/facet/#{id}?q=#{q}"
          expect(response.status).to eq(200)
          expect(json_response).to eq({ "Cat" => 1 })
        end
      end

      context 'with f' do
        let!(:work2) { create(:work, visibility: 'open', keyword: ['Dog']) }
        let(:id) { 'keyword_sim' }
        let(:f) { 'Dog' }

        it 'filters results' do
          get "/api/v1/tenant/#{account.id}/search/facet/#{id}?f[keyword_sim][]=#{f}"
          expect(response.status).to eq(200)
          expect(json_response).to eq({ "Dog" => 1 })
        end
      end

      context 'with per_page' do
        let!(:work2) { create(:work, visibility: 'open', keyword: ['Cat']) }
        let!(:work3) { create(:work, visibility: 'open', keyword: ['Dog']) }
        let(:per_page) { 1 }
        let(:id) { 'keyword_sim' }
  
        it 'limits the number of facet results' do
          get "/api/v1/tenant/#{account.id}/search/facet/#{id}?per_page=#{per_page}"
          expect(response.status).to eq(200)
          expect(json_response.size).to eq 1
          expect(json_response).to eq({ "Cat" => 2 })
        end

        context 'with page' do
          let(:page) { 2 }
    
          it 'limits the number of facet results and offsets to page' do
            get "/api/v1/tenant/#{account.id}/search/facet/#{id}?per_page=#{per_page}&page=#{page}"
            expect(response.status).to eq(200)
            expect(json_response.size).to eq 1
            expect(json_response).to eq({ "Dog" => 1 })
          end
        end
      end  
    end
  end
end