require 'spec_helper'

describe "User Pages" do

  subject { page }

  describe "Registration Pages" do

    context "with valid attributes" do

      before do
        visit new_user_registration_path
        valid_signup "investor"
      end

      it "creates a new user" do
        expect { click_button "Sign up" }.to change(User, :count).by(1)
      end

      it "redirects to plans page" do
        click_button "Sign up"
        page.should have_content("Select Plan")
      end
    end

    context "with invalid attributes" do
      it "does not create a new user" do
        visit new_user_registration_path
        expect { click_button "Sign up" }.not_to change(User, :count) 
      end
    end
  end

  describe "entrepreneur user" do

    let!(:user) { FactoryGirl.create(:user, user_type: "entrepreneur") }
    let!(:plan) { FactoryGirl.create(:plan_with_subscription, user: user, user_project_limit: 1) }
    before { sign_in user }


    describe "profile page" do

      context "before user has updated their profile" do
        it "alerts the user to update their profile" do
          visit user_path(user)
          page.should have_content("Start filling out your profile")
        end
      end

      context "after user has updated their profile" do

        let!(:project) { FactoryGirl.create(:project, user: user) }
        before { visit user_path(user) }

        it "displays profile information" do
          page.should have_content(project.company_name) 
          page.should have_content(project.location_state_city) 
          page.should have_content(project.description) 
        end

        #it "displays company image" do
        #  page.should have_selector("img[alt='#{project.company_name}']")
        #end
      end
    end
  end
end
