require_relative "test_helper"

class ActiveRecordTest < Minitest::Test
  def setup
    User.delete_all
  end

  def test_relation
    users = create_users
    df = Polars::DataFrame.new(User.order(:id))
    assert_equal ["id", "name", "number"], df.columns
    assert_series users.map(&:id), df["id"]
    assert_series users.map(&:name), df["name"]
    assert_equal Polars::Int64, df["number"].dtype
  end

  def test_result
    users = create_users
    df = Polars::DataFrame.new(User.connection.select_all("SELECT * FROM users ORDER BY id"))
    assert_equal ["id", "name", "number"], df.columns
    assert_series users.map(&:id), df["id"]
    assert_series users.map(&:name), df["name"]
    assert_equal Polars::Int64, df["number"].dtype
  end

  def test_read_sql_relation
    users = create_users
    df = Polars.read_sql(User.order(:id))
    assert_equal ["id", "name", "number"], df.columns
    assert_series users.map(&:id), df["id"]
    assert_series users.map(&:name), df["name"]
    assert_equal Polars::Int64, df["number"].dtype
  end

  def test_read_sql_result
    users = create_users
    df = Polars.read_sql(User.connection.select_all("SELECT * FROM users ORDER BY id"))
    assert_equal ["id", "name", "number"], df.columns
    assert_series users.map(&:id), df["id"]
    assert_series users.map(&:name), df["name"]
    assert_equal Polars::Int64, df["number"].dtype
  end

  def test_read_sql_string
    users = create_users
    df = Polars.read_sql("SELECT * FROM users ORDER BY id")
    assert_equal ["id", "name", "number"], df.columns
    assert_series users.map(&:id), df["id"]
    assert_series users.map(&:name), df["name"]
    assert_equal Polars::Int64, df["number"].dtype
  end

  def test_read_sql_unsupported
    error = assert_raises(ArgumentError) do
      Polars.read_sql(Object.new)
    end
    assert_equal "Expected ActiveRecord::Relation, ActiveRecord::Result, or String", error.message
  end

  private

  def create_users
    3.times.map { |i| User.create!(name: "User #{i}", number: i) }
  end
end
