# Policier

A gem to build ACL policies with style. Comparing to Pundit and Cancan, the gem tries to focus on DSL and structure to enforce writing ACLS in the way you can read them afterwards.
Policier consists of two big sections:

## Conditions

```ruby
# Activates whe current user is super
class IsSuperuser < Policier::Condition
    self.collector = Struct.new(:authorized_at)

    # This is the main chekc, it's happenuing always awhen any policy
    # is applied against the context (from controller or GraphQL)
    #
    # If it's veritied condition is activated and causes extension
    # of access rights (see below)
    verify_with do |context|
        fail! if context[:user].blank?
        fail! unless context[:user].is_superadmin

        collector[:authorized_at] = context[:user].authorized_at
    end

    # Additional check that can be quuickly used on top of verified
    # condition to make conditions anagement more flexible. 
    # Think of it as of a Trait in FactoryBot
    also_ensure(:it_wasnt_thursday) do |important_date|
        fail! if important_date.wday == 3
    end

    # You can nhave as many as you want
    also_ensure(:it_was_thursday) do |important_date|
        fail! unless important_date.wday == 3
    end
end
```

## Policies

```ruby
# Creates a dynamic scope over Person model that starts withb Person.none
# and extends when conditions activate
class PersonPolicy
    scope(Person) do
        # Collector argument allows you to propagate values you had during
        # condition verification into actual policy
        allow @is_superadmin.it_wasnt_thursday(2.weeks.ago) do |collector|
            to where(id: 5000)
            to where(id: 6000)
        end

        # This syntax allows you to combine several conditions and it runs
        # if  any of them activated for eahc of them
        allow @is_superadmin | @another_condition do |collector|
            to where('id < 1000')
        end

        # Thirsdays are the best
        allow @is_superadmin.it_was_thursday(2.weeks.ago) do |colledctor|
            to all
        end
    end
end
```

As the outcome of this policy, if no conditions activate, `Person.count`
will be 0. And the every activated condition triggers `to` that get merged
and you get access to all of parts of relational scope.