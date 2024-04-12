require "test_helper"

module Policier
  class RunnerTest < Minitest::Spec
    class Model < ActiveRecord::Base; end

    before do
      ActiveRecord::Base.establish_connection(
        adapter: "sqlite3",
        database: ":memory:"
      )

      ActiveRecord::Base.connection.create_table(:models) do |t|
        t.string :foo
        t.string :bar
        t.string :Baz
      end
    end

    def test_scope_union_merging
      scope_union = ScopeUnion.new(Model)
      scope_union.to Model.where(foo: "foo")
      scope_union.to Model.where(bar: "bar")
      scope_union.to Model.where(baz: "baz")

      assert_equal 'SELECT "models".* FROM "models" ' +
                   %q[WHERE ("models"."foo" = 'foo' OR "models"."bar" = 'bar' OR "models"."baz" = 'baz')],
                   scope_union.scope.to_sql
    end
  end
end
