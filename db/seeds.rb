# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# 30.times do
#   body = Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 4)
#   title = Faker::Hipster.sentence(word_count: 3)
#   Question.create title:, body:
# end

# с помощью send можно вызывать приватные методы
# User.find_each do |u|
#   u.send(:set_gravatar_hash)
#   u.save
# end

30.times do
  title = Faker::Hipster.word
  Tag.create title:
end
