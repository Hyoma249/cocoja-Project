class ApplicationRecord < ActiveRecord::Base
  # この ApplicationRecord は他のモデルの土台になるけど、自分自身は直接使わないよ！
  primary_abstract_class
end
