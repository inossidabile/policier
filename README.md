# Policier (WIP!)

Ongoing research of DSL for authorization.

## General

Enforces the policy inside the block.

```ruby
RolePolicy.enforce(user: user, roles: roles) do
  # ...
end
```

## Policies

Compiles policy for each evaluator (controller, model, etc.) from conditions.

```ruby
class RolePolicy < Policier::Policy
  restrict Controller do
    allow UserCondition & RoleCondition[:reader] do
      to :index, :show
    end

    allow UserCondition[:superadmin] do
      to :*
    end
  end

  restrict Model do
    allow UserCondition & RoleCondition[:reader] do
      to query.where(published: true)
    end

    allow UserCondition[:superadmin] do
      to query.all
    end
  end
```

## Conditions

```ruby
class UserCondition < Policier::Condition
  def initialize(user:)
    super
  end

  verify do
    deny! if @user.nil?
    pass
  end

  verify :superadmin do
    pass! if @user&.is_superadmin
  end
end

class RoleCondition < Policier::Condition
  def initialize(roles:)
    super
  end

  verify_with do |name|
    pass if @roles.include?(name)
  end
end
```
