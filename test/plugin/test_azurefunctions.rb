require 'helper'

class AzureFunctionsOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    endpoint https://yoichikademo1.azurewebsites.net/api/HttpTriggerFunction
    function_key aRVQ7Lj0vzDhY0JBYF8gpDzDCyEBxLwhO51JSC7X5dZFbTvROs7uNg==
    key_names postid,user,content,tag
    add_time_field true
    localtime true
    add_tag_field true
    tag_field_name tag
  ]
  # CONFIG = %[
  #   path #{TMP_DIR}/out_file_test
  #   compress gz
  #   utc
  # ]

  def create_driver(conf = CONFIG, tag='azurefunctions.test')
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::AzureFunctionsOutput, tag).configure(conf)
  end

  def test_configure
    #### set configurations
    # d = create_driver %[
    #   path test_path
    #   compress gz
    # ]
    #### check configurations
    # assert_equal 'test_path', d.instance.path
    # assert_equal :gz, d.instance.compress
  end

  def test_format
    d = create_driver

    # time = Time.parse("2011-01-02 13:14:15 UTC").to_i
    # d.emit({"a"=>1}, time)
    # d.emit({"a"=>2}, time)

    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":1}\n]
    # d.expect_format %[2011-01-02T13:14:15Z\ttest\t{"a":2}\n]

    # d.run
  end

  def test_write
    d = create_driver

    time = Time.parse("2016-01-28 13:14:15 UTC").to_i
    d.emit(
        {
            "postid" => "10001",
            "user"=> "ladygaga",
            "content" => "post by ladygaga",
            "tag" => "azurefunctions.debug",
            "posttime" =>"2016-11-31T00:00:00Z"
        }, time)

    d.emit(
        {
            "postid" => "10002",
            "user"=> "katyperry",
            "content" => "post by katyperry",
            "tag" => "azurefunctions.debug",
            "posttime" =>"2016-11-31T00:00:00Z"
        }, time)

    d.emit(
        {
            "postid" => "10003",
            "tag" => "azurefunctions.debug",
            "time" =>"2016-11-31T00:00:00Z"
        }, time)

    d.emit(
        {
            "posttime" => "2016-11-31T00:00:00Z"
        }, time)

    data = d.run
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end

