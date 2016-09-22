class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.integer :uid, null: false, unsigned: true, limit: 8
      t.string :nickname
      t.string :name
      t.string :email
      t.string :image_url
      t.string :description
      t.string :access_token
      t.string :access_token_secret

      t.timestamps
    end

    add_index :users, %i(provider uid), unique: true
  end
end
