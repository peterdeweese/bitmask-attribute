require 'test_helper'

class TestBitmaskAttribute < Test::Unit::TestCase

  context "Campaign" do

    teardown do
      Company.destroy_all
      Campaign.destroy_all
    end

    should "can assign single value to bitmask" do
      assert_stored Campaign.new(:medium => :web), :web
    end

    should "can assign multiple values to bitmask" do
      assert_stored Campaign.new(:medium => [:web, :print]), :web, :print
    end

    should "can add single value to bitmask" do
      campaign = Campaign.new(:medium => [:web, :print])
      assert_stored campaign, :web, :print
      campaign.medium << :phone
      assert_stored campaign, :web, :print, :phone
    end

    should "ignores duplicate values added to bitmask" do
      campaign = Campaign.new(:medium => [:web, :print])
      assert_stored campaign, :web, :print
      campaign.medium << :phone
      assert_stored campaign, :web, :print, :phone
      campaign.medium << :phone
      assert_stored campaign, :web, :print, :phone
      assert_equal 1, campaign.medium.select { |value| value == :phone }.size
    end

    should "can assign new values at once to bitmask" do
      campaign = Campaign.new(:medium => [:web, :print])
      assert_stored campaign, :web, :print
      campaign.medium = [:phone, :email]
      assert_stored campaign, :phone, :email
    end

    should "can save bitmask to db and retrieve values transparently" do
      campaign = Campaign.new(:medium => [:web, :print])
      assert_stored campaign, :web, :print
      assert campaign.save
      assert_stored Campaign.find(campaign.id), :web, :print
    end

    should "can add custom behavor to value proxies during bitmask definition" do
      campaign = Campaign.new(:medium => [:web, :print])
      assert_raises NoMethodError do
        campaign.medium.worked?
      end
      assert_nothing_raised do
        campaign.misc.worked?
      end
      assert campaign.misc.worked?
    end

    should "not use unsupported values" do

      assert_unsupported { Campaign.new(:medium => [:web, :print, :this_will_fail]) }

      campaign = Campaign.new(:medium => [:web, :print])
      assert campaign.medium.include?(:web)
      assert campaign.medium.include?(:print)

      assert_unsupported { campaign.medium << :this_will_also_fail << :email }
      assert !campaign.medium.include?(:this_will_also_fail)
      assert campaign.medium.include?(:web)
      assert campaign.medium.include?(:print)
      assert !campaign.medium.include?(:email)

      assert_unsupported { campaign.medium << :email << :this_will_fail_also }
      assert campaign.medium.include?(:web)
      assert campaign.medium.include?(:print)
      assert campaign.medium.include?(:email)

      assert_nothing_raised { campaign.medium = [:phone] }
      assert_unsupported { campaign.medium = [:so_will_this, :print, :and_this, :email] }
      assert !campaign.medium.include?(:so_will_this)
      assert !campaign.medium.include?(:and_this)
      assert !campaign.medium.include?(:print)
      assert !campaign.medium.include?(:email)
      assert campaign.medium.include?(:phone)

      campaign = Campaign.new(:medium => [:web, :print])
      assert_nothing_raised { campaign.medium.push(:phone, :email)}
      assert_equal(4, campaign.medium.count)
      assert_unsupported { campaign.medium.push(:fail1, :fail2) }
      assert_nothing_raised { campaign.medium.push(:phone, :email) }
      assert_nothing_raised { campaign.medium << :web << :print }
      assert_equal(4, campaign.medium.count)

    end

    should "can determine bitmasks using convenience method" do
      assert Campaign.bitmask_for_medium(:web, :print)
      assert_equal(
        Campaign.bitmasks[:medium][:web] | Campaign.bitmasks[:medium][:print],
        Campaign.bitmask_for_medium(:web, :print)
      )
    end

    should "assert use of unknown value in convenience method will result in exception" do
      assert_unsupported { Campaign.bitmask_for_medium(:web, :and_this_isnt_valid)  }
    end

    should "hash of values is with indifferent access" do
      string_bit = nil
      assert_nothing_raised do
        assert (string_bit = Campaign.bitmask_for_medium('web', 'print'))
      end
      assert_equal Campaign.bitmask_for_medium(:web, :print), string_bit
    end

    should "save bitmask with non-standard attribute names" do
      campaign = Campaign.new(:Legacy => [:upper, :case])
      assert campaign.save
      assert_equal [:upper, :case], Campaign.find(campaign.id).Legacy
    end

    should "ignore blanks fed as values" do
      campaign = Campaign.new(:medium => [:web, :print, ''])
      assert_stored campaign, :web, :print
    end

    context "checking" do

      setup { @campaign = Campaign.new(:medium => [:web, :print]) }

      context "for a single value" do

        should "be supported by an attribute_for_value convenience method" do
          assert @campaign.medium_for_web?
          assert @campaign.medium_for_print?
          assert !@campaign.medium_for_email?
        end

        should "be supported by the simple predicate method" do
          assert @campaign.medium?(:web)
          assert @campaign.medium?(:print)
          assert !@campaign.medium?(:email)
        end

      end

      context "for multiple values" do

        should "be supported by the simple predicate method" do
          assert @campaign.medium?(:web, :print)
          assert !@campaign.medium?(:web, :email)
        end

      end

    end

    context "scopes" do

      setup do
        @company = Company.create(:name => "Test Co, Intl.")
        @campaign1 = @company.campaigns.create :medium => [:web, :print]
        @campaign2 = @company.campaigns.create
        @campaign3 = @company.campaigns.create :medium => [:web, :email]
      end

      should "support retrieval by any value" do
        assert_equal [@campaign1, @campaign3], @company.campaigns.with_medium
      end

      should "support retrieval by one matching value" do
        assert_equal [@campaign1], @company.campaigns.with_medium(:print)
      end

      should "support retrieval by all matching values" do
        assert_equal [@campaign1], @company.campaigns.with_medium(:web, :print)
        assert_equal [@campaign3], @company.campaigns.with_medium(:web, :email)
      end

      should "support retrieval for a value that is not set" do
        assert_equal [@campaign2], @company.campaigns.without_medium(:web)
        assert_equal [@campaign2, @campaign3], @company.campaigns.without_medium(:print)
        assert_equal [@campaign1, @campaign2], @company.campaigns.without_medium(:email)
      end

      should "support retrieval for no values" do
        assert_equal [@campaign2], @company.campaigns.no_medium
      end

    end

    should "can check if at least one value is set" do
      campaign = Campaign.new(:medium => [:web, :print])

      assert campaign.medium?

      campaign = Campaign.new

      assert !campaign.medium?
    end

    should "find by bitmask values" do

      campaign1 = Campaign.new(:medium => [:web, :print])
      assert campaign1.save

      campaign2 = Campaign.new(:medium => [:web])
      assert campaign2.save

      campaign3 = Campaign.new(:medium => [:print])
      assert campaign3.save

      assert_equal(
        Campaign.find(:all, :conditions => ['medium & ? <> 0', Campaign.bitmask_for_medium(:print)]),
        Campaign.medium_for_print
      )

      assert_equal(
        Campaign.find(:all, :conditions => ['medium & ? <> 0', Campaign.bitmask_for_medium(:web)]),
        Campaign.medium_for_web
      )

      assert_equal(2, Campaign.medium_for_print.size)
      assert_equal(2, Campaign.medium_for_web.size)
      assert_equal(1, Campaign.medium_for_web.medium_for_print.size)
      assert_equal(1, Campaign.medium_for_print.medium_for_web.size)

      assert_equal [], Campaign.medium_for_email
      assert_equal [], Campaign.medium_for_web.medium_for_email

    end

    should "find no values" do
      campaign = Campaign.create(:medium => [:web, :print])
      assert campaign.save

      assert_equal [], Campaign.no_medium

      campaign.medium = []
      assert campaign.save

      assert_equal [campaign], Campaign.no_medium
    end

    #######
    private
    #######

    def assert_unsupported(&block)
      assert_raises(ArgumentError, &block)
    end

    def assert_stored(record, *values)
      values.each do |value|
        assert record.medium.any? { |v| v.to_s == value.to_s }, "Values #{record.medium.inspect} does not include #{value.inspect}"
      end
      full_mask = values.inject(0) do |mask, value|
        mask | Campaign.bitmasks[:medium][value]
      end
      assert_equal full_mask, record.medium.to_i
    end

  end

end
