require File.expand_path '../../../test_config', __FILE__
require 'timecop'

describe CacheHelpers do
  include CacheHelpers
  include CityHelpers

  describe "last_modified_city_date" do
    it "should return the last section updated_at" do
      section1 = Timecop.freeze(Date.today - 4) do
        Section.create(line_id: 222)
      end

      system1 = Timecop.freeze(Date.today - 3) do
        System.create(city_id: 33)
      end

      system2 = Timecop.freeze(Date.today - 2) do
        System.create(city_id: 33)
      end

      section2  = Section.create(line_id: 222)

      assert_equal section2.updated_at, last_modified_city_date
    end

    it "should return the last system updated_at" do
      section1 = Timecop.freeze(Date.today - 4) do
        Section.create(line_id: 222)
      end

      system1 = Timecop.freeze(Date.today - 3) do
        System.create(city_id: 33)
      end

      section2 = Timecop.freeze(Date.today - 2) do
        Section.create(line_id: 222)
      end

      system2 = System.create(city_id: 33)

      assert_equal system2.updated_at, last_modified_city_date
    end

    it "should return the last DeletedFeature created_at" do
      section1 = Timecop.freeze(Date.today - 4) do
        Section.create(line_id: 222)
      end

      system1 = Timecop.freeze(Date.today - 3) do
        System.create(city_id: 33)
      end

      section2 = Timecop.freeze(Date.today - 2) do
        Section.create(line_id: 222)
      end

      deleted_feature = DeletedFeature.create(feature_class: 'Section', city_id: 33)

      assert_equal deleted_feature.created_at, last_modified_city_date
    end
  end

  describe "last_modified_source_feature" do
    before do
      @city = City.create(name: 'Testonia', system_name: '', url_name: 'testonia')
      @line = Line.create(name: 'Line 1', city_id: @city.id)

      @city2 = City.create(name: 'Testonia2', system_name: '', url_name: 'testonia2')
      @line2 = Line.create(name: 'Line 1', city_id: @city2.id)
    end

    describe "sections" do
      it "should return the last modified feature updated_at" do
        deleted_feature = Timecop.freeze(Date.today - 3) do
          DeletedFeature.create(city_id: @city.id, feature_class: 'Section')
        end

        section1 = Timecop.freeze(Date.today - 2) do
          Section.create(line_id: @line.id)
        end

        section2 = Timecop.freeze(Date.today - 1 ) do
          Section.create(line_id: @line.id)
        end

        section_of_another_city = Section.create(line_id: @line2.id)

        assert_equal section2.updated_at, last_modified_source_feature(@city, 'sections')
      end

      it "should return the last deleted_feature created_at" do
        section1 = Timecop.freeze(Date.today - 3) do
          Section.create(line_id: @line.id)
        end

        section2 = Timecop.freeze(Date.today - 2) do
          Section.create(line_id: @line.id)
        end

        deleted_feature = Timecop.freeze(Date.today - 1) do
          DeletedFeature.create(city_id: @city.id, feature_class: 'Section')
        end

        section_of_another_city = Section.create(line_id: @line2.id)

        assert_equal deleted_feature.created_at, last_modified_source_feature(@city, 'sections')
      end
    end

    describe "stations" do
      it "should return the last modified feature updated_at" do
        deleted_feature = Timecop.freeze(Date.today - 3) do
          DeletedFeature.create(city_id: @city.id, feature_class: 'Station')
        end

        station1 = Timecop.freeze(Date.today - 2) do
          Station.create(line_id: @line.id)
        end

        station2 = Timecop.freeze(Date.today - 1 ) do
          Station.create(line_id: @line.id)
        end

        station_of_another_city = Station.create(line_id: @line2.id)

        assert_equal station2.updated_at, last_modified_source_feature(@city, 'stations')
      end

      it "should return the last deleted_feature created_at" do
        station1 = Timecop.freeze(Date.today - 3) do
          Station.create(line_id: @line.id)
        end

        station2 = Timecop.freeze(Date.today - 2) do
          Station.create(line_id: @line.id)
        end

        deleted_feature = Timecop.freeze(Date.today - 1) do
          DeletedFeature.create(city_id: @city.id, feature_class: 'Station')
        end

        station_of_another_city = Station.create(line_id: @line2.id)

        assert_equal deleted_feature.created_at, last_modified_source_feature(@city, 'stations')
      end
    end
  end
end