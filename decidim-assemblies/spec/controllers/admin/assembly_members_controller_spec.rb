# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Assemblies
    module Admin
      describe AssemblyMembersController, type: :controller do
        routes { Decidim::Assemblies::AdminEngine.routes }

        let(:organization) { create(:organization) }
        let(:current_user) { create(:user, :confirmed, :admin, organization: organization) }
        let!(:assembly) { create(:assembly, organization: organization) }
        let(:params) { { assembly_slug: assembly.slug } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = assembly
          sign_in current_user
        end

        describe "GET users in json format" do
          let(:user) { create(:user, organization: organization) }

          context "when there are no results" do
            it "returns an empty json array" do
              get :users, format: :json, params: params.merge!(term: "#0")
              expect(response.body).to eq([].to_json)
            end
          end

          context "when searching by name" do
            it "returns the id, name and nickname for filtered users" do
              params[:term] = user.name.to_s
              get :users, format: :json, params: params
              expect(response.body).to eq([{ value: user.id, label: user.name, caption: "@#{user.nickname}" }].to_json)
            end
          end

          context "when searching by nickname" do
            it "returns the id, name and nickname for filtered users" do
              params[:term] = "@#{user.nickname}"
              get :users, format: :json, params: params
              expect(response.body).to eq([{ value: user.id, label: user.name, caption: "@#{user.nickname}" }].to_json)
            end
          end
        end
      end
    end
  end
end
