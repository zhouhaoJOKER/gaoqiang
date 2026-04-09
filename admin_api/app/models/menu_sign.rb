class MenuSign < ApplicationRecord
    belongs_to :menu, class_name: "Menu", optional: true
end
