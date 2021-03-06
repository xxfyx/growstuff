## DEPRECATION NOTICE: Do not add new tests to this file!
##
## View and controller tests are deprecated in the Growstuff project.
## We no longer write new view and controller tests, but instead write
## feature tests (in spec/features) using Capybara (https://github.com/jnicklas/capybara).
## These test the full stack, behaving as a browser, and require less complicated setup
## to run. Please feel free to delete old view/controller tests as they are reimplemented
## in feature tests.
##
## If you submit a pull request containing new view or controller tests, it will not be
## merged.

require 'rails_helper'

describe "photos/show" do
  let(:photo) { FactoryGirl.create :photo, owner: member }
  before { @photo = photo }

  let(:member) { FactoryGirl.create :member }

  let(:harvest) { FactoryGirl.create :harvest, owner: member }
  let(:planting) { FactoryGirl.create :planting, owner: member }
  let(:seed) { FactoryGirl.create :seed, owner: member }
  let(:garden) { FactoryGirl.create :garden, owner: member }

  shared_examples "photo data renders" do
    it "shows the image" do
      assert_select "img[src='#{@photo.fullsize_url}']"
    end

    it "links to the owner's profile" do
      assert_select "a", href: @photo.owner
    end

    it "shows a link to the original image" do
      assert_select "a", href: @photo.link_url, text: "View on Flickr"
    end

    it "links to harvest" do
      assert_select "a", href: harvest_path(harvest)
    end
    it "links to planting" do
      assert_select "a", href: planting_path(planting)
    end
    it "links to garden" do
      assert_select "a", href: garden_path(garden)
    end
    it "links to seeds" do
      assert_select "a", href: seed_path(seed)
    end
  end

  shared_examples "No links to change data" do
    it "does not have a delete button" do
      assert_select "a[href='#{photo_path(@photo)}']", false
    end
  end

  context "signed in as owner" do
    before(:each) do
      controller.stub(:current_user) { member }
      render
    end
    include_examples "photo data renders"

    it "has a delete button" do
      assert_select "a[href='#{photo_path(@photo)}']"
    end
  end

  context "signed in as another member" do
    before(:each) do
      controller.stub(:current_user) { FactoryGirl.create :member }
      render
    end
    include_examples "photo data renders"
    include_examples "No links to change data"
  end

  context "not signed in" do
    before(:each) do
      controller.stub(:current_user) { nil }
      render
    end
    include_examples "photo data renders"
    include_examples "No links to change data"
  end

  context "CC-licensed photo" do
    before(:each) do
      controller.stub(:current_user) { nil }
      # @photo = assign(:photo, FactoryGirl.create(:photo, owner: @member))
      @photo.harvests << harvest
      @photo.plantings << planting
      @photo.seeds << seed
      @photo.gardens << garden
      render
    end
    it "links to the CC license" do
      assert_select "a", href: @photo.license_url,
                         text: @photo.license_name
    end
  end

  context "unlicensed photo" do
    before(:each) do
      controller.stub(:current_user) { nil }
      @photo = assign(:photo, FactoryGirl.create(:unlicensed_photo))
      render
    end

    it "contains the phrase 'All rights reserved'" do
      rendered.should have_content "All rights reserved"
    end
  end
end
