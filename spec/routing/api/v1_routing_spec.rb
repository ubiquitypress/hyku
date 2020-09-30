RSpec.describe 'REST API V1 Routing', type: :routing do
  describe 'tenant' do
    describe 'RESTful routes' do
      it "routes to #index via GET" do
        expect(get: "/api/v1/tenant").to route_to("api/v1/tenant#index", format: :json)
      end
      it "routes to #create via POST" do
        expect(post: "/api/v1/tenant").to route_to("api/v1/tenant#create", format: :json)
      end
      it "routes to #new via GET" do
        expect(get: "/api/v1/tenant/new").to route_to("api/v1/tenant#new", format: :json)
      end
      it "routes to #edit via GET" do
        expect(get: "/api/v1/tenant/abc/edit").to route_to("api/v1/tenant#edit", id: 'abc', format: :json)
      end
      it "routes to #show via GET" do
        expect(get: "/api/v1/tenant/abc").to route_to("api/v1/tenant#show", id: 'abc', format: :json)
      end
      it "routes to #update via PATCH" do
        expect(patch: "/api/v1/tenant/abc").to route_to("api/v1/tenant#update", id: 'abc', format: :json)
      end
      it "routes to #update via PUT" do
        expect(put: "/api/v1/tenant/abc").to route_to("api/v1/tenant#update", id: 'abc', format: :json)
      end
      it "routes to #destroy via DELETE" do
        expect(delete: "/api/v1/tenant/abc").to route_to("api/v1/tenant#destroy", id: 'abc', format: :json)
      end
    end

    describe 'member routes' do
      describe "work" do
        describe 'RESTful routes' do
          it "routes to #index via GET" do
            expect(get: "/api/v1/tenant/abc/work").to route_to("api/v1/work#index", tenant_id: 'abc', format: :json)
          end
          it "routes to #create via POST" do
            expect(post: "/api/v1/tenant/abc/work").to route_to("api/v1/work#create", tenant_id: 'abc', format: :json)
          end
          it "routes to #new via GET" do
            expect(get: "/api/v1/tenant/abc/work/new").to route_to("api/v1/work#new", tenant_id: 'abc', format: :json)
          end
          it "routes to #edit via GET" do
            expect(get: "/api/v1/tenant/abc/work/def/edit").to route_to("api/v1/work#edit", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #show via GET" do
            expect(get: "/api/v1/tenant/abc/work/def").to route_to("api/v1/work#show", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PATCH" do
            expect(patch: "/api/v1/tenant/abc/work/def").to route_to("api/v1/work#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PUT" do
            expect(put: "/api/v1/tenant/abc/work/def").to route_to("api/v1/work#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #destroy via DELETE" do
            expect(delete: "/api/v1/tenant/abc/work/def").to route_to("api/v1/work#destroy", id: 'def', tenant_id: 'abc', format: :json)
          end
        end
    
        describe 'member routes' do
          it "routes to #manifest via GET" do
            expect(get: "/api/v1/tenant/abc/work/def/manifest").to route_to("api/v1/work#manifest", tenant_id: 'abc', id: 'def', format: :json)
          end
          it "routes to #files via GET" do
            expect(get: "/api/v1/tenant/abc/work/def/files").to route_to("api/v1/files#index", tenant_id: 'abc', work_id: 'def', format: :json)
          end
          it "routes to #featured_works via POST" do
            expect(post: "/api/v1/tenant/abc/work/def/featured_works").to route_to("api/v1/featured_works#create", tenant_id: 'abc', work_id: 'def', format: :json)
          end
          it "routes to #featured_works via DELETE" do
            expect(delete: "/api/v1/tenant/abc/work/def/featured_works").to route_to("api/v1/featured_works#destroy", tenant_id: 'abc', work_id: 'def', format: :json)
          end
          it "routes to #reviews via POST" do
            expect(post: "/api/v1/tenant/abc/work/def/reviews").to route_to("api/v1/reviews#create", tenant_id: 'abc', work_id: 'def', format: :json)
          end
        end
      end

      describe 'collection' do
        describe 'RESTful routes' do
          it "routes to #index via GET" do
            expect(get: "/api/v1/tenant/abc/collection").to route_to("api/v1/collection#index", tenant_id: 'abc', format: :json)
          end
          it "routes to #create via POST" do
            expect(post: "/api/v1/tenant/abc/collection").to route_to("api/v1/collection#create", tenant_id: 'abc', format: :json)
          end
          it "routes to #new via GET" do
            expect(get: "/api/v1/tenant/abc/collection/new").to route_to("api/v1/collection#new", tenant_id: 'abc', format: :json)
          end
          it "routes to #edit via GET" do
            expect(get: "/api/v1/tenant/abc/collection/def/edit").to route_to("api/v1/collection#edit", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #show via GET" do
            expect(get: "/api/v1/tenant/abc/collection/def").to route_to("api/v1/collection#show", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PATCH" do
            expect(patch: "/api/v1/tenant/abc/collection/def").to route_to("api/v1/collection#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PUT" do
            expect(put: "/api/v1/tenant/abc/collection/def").to route_to("api/v1/collection#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #destroy via DELETE" do
            expect(delete: "/api/v1/tenant/abc/collection/def").to route_to("api/v1/collection#destroy", id: 'def', tenant_id: 'abc', format: :json)
          end
        end
      end

      describe 'search' do
        describe 'RESTful routes' do
          it "routes to #index via GET" do
            expect(get: "/api/v1/tenant/abc/search").to route_to("api/v1/search#index", tenant_id: 'abc', format: :json)
          end
          it "routes to #create via POST" do
            expect(post: "/api/v1/tenant/abc/search").to route_to("api/v1/search#create", tenant_id: 'abc', format: :json)
          end
          it "routes to #new via GET" do
            expect(get: "/api/v1/tenant/abc/search/new").to route_to("api/v1/search#new", tenant_id: 'abc', format: :json)
          end
          it "routes to #edit via GET" do
            expect(get: "/api/v1/tenant/abc/search/def/edit").to route_to("api/v1/search#edit", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #show via GET" do
            expect(get: "/api/v1/tenant/abc/search/def").to route_to("api/v1/search#show", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PATCH" do
            expect(patch: "/api/v1/tenant/abc/search/def").to route_to("api/v1/search#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #update via PUT" do
            expect(put: "/api/v1/tenant/abc/search/def").to route_to("api/v1/search#update", id: 'def', tenant_id: 'abc', format: :json)
          end
          it "routes to #destroy via DELETE" do
            expect(delete: "/api/v1/tenant/abc/search/def").to route_to("api/v1/search#destroy", id: 'def', tenant_id: 'abc', format: :json)
          end
        end
    
        describe 'collection routes' do
          it "routes to #facet via GET" do
            expect(get: "/api/v1/tenant/abc/search/facet/def").to route_to("api/v1/search#facet", tenant_id: 'abc', id: 'def', format: :json)
          end
        end
      end
      
      describe 'users' do
        describe 'collection routes' do
          it "routes to #login via POST" do
            expect(post: "/api/v1/tenant/abc/users/login").to route_to("api/v1/sessions#create", tenant_id: 'abc', format: :json)
          end
          it "routes to #log_out via GET" do
            expect(get: "/api/v1/tenant/abc/users/log_out").to route_to("api/v1/sessions#destroy", tenant_id: 'abc', format: :json)
          end
          it "routes to #refresh via POST" do
            expect(post: "/api/v1/tenant/abc/users/refresh").to route_to("api/v1/sessions#refresh", tenant_id: 'abc', format: :json)
          end
          it "routes to #signup via POST" do
            expect(post: "/api/v1/tenant/abc/users/signup").to route_to("api/v1/registrations#create", tenant_id: 'abc', format: :json)
          end
        end
      end

      it "routes to #highlights via GET" do
        expect(get: "/api/v1/tenant/abc/highlights").to route_to("api/v1/highlights#index", tenant_id: 'abc', format: :json)
      end
      it "routes to #contact_form via POST" do
        expect(post: "/api/v1/tenant/abc/contact_form").to route_to("api/v1/contact_form#create", tenant_id: 'abc', format: :json)
      end
    end
  end

  describe 'errors' do
    it "routes to #errors via GET" do
      expect(get: "/api/v1/errors").to route_to("api/v1/errors#index", format: :json)
    end
  end
end

