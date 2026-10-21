# Owners can now log in with their phone number, so a phone must point to
# exactly one account. The model validation gives a friendly error message; this
# index is the real guarantee (it also makes the login lookup fast).
#
# Why a new migration instead of editing CreateUsers? CreateUsers has already
# run. Editing it would change nothing in any database where it already ran
# (yours now, production later). Migrations are history: add, don't rewrite.
class AddUniqueIndexToUsersPhone < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :phone, unique: true
  end
end
