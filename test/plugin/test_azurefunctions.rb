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

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::AzureFunctionsOutput).configure(conf)
  end

  def test_configure
    d = create_driver

    assert_equal 'https://yoichikademo1.azurewebsites.net/api/HttpTriggerFunction',
                 d.instance.endpoint
    assert_equal 'aRVQ7Lj0vzDhY0JBYF8gpDzDCyEBxLwhO51JSC7X5dZFbTvROs7uNg==',
                 d.instance.function_key
    assert_equal ["postid", "user", "content", "tag"], d.instance.key_names
    assert_true d.instance.localtime
    assert_true d.instance.add_time_field
    assert_equal 'time', d.instance.time_field_name
    assert_true d.instance.add_tag_field
    assert_equal 'tag', d.instance.tag_field_name
  end

  def test_format
    d = create_driver

    time = event_time("2011-01-02 13:14:15 UTC")
    d.run(default_tag: 'documentdb.test') do
      d.feed(time, {"a"=>1})
      d.feed(time, {"a"=>2})
    end

    # assert_equal EXPECTED1, d.formatted[0]
    # assert_equal EXPECTED2, d.formatted[1]
  end

  def test_write
    d = create_driver

    time = event_time("2016-01-28 13:14:15 UTC")
    data = d.run(default_tag: 'azurefunctions.test') do
      d.feed(
          time,
          {
              "postid" => "10001",
              "user"=> "ladygaga",
              "content" => "post by ladygaga",
              "tag" => "azurefunctions.debug",
              "posttime" =>"2016-11-31T00:00:00Z"
          })

      d.feed(
          time,
          {
              "postid" => "10002",
              "user"=> "katyperry",
              "content" => "post by katyperry",
              "tag" => "azurefunctions.debug",
              "posttime" =>"2016-11-31T00:00:00Z"
          })

      d.feed(
          time,
          {
              "postid" => "10003",
              "tag" => "azurefunctions.debug",
              "time" =>"2016-11-31T00:00:00Z"
          })

      d.feed(
          time,
          {
              "posttime" => "2016-11-31T00:00:00Z"
          })
    end
    puts data
    # ### FileOutput#write returns path
    # path = d.run
    # expect_path = "#{TMP_DIR}/out_file_test._0.log.gz"
    # assert_equal expect_path, path
  end
end
