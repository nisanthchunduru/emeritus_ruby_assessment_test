class User < ApplicationRecord
  # enum kind: { student: 0, teacher: 1, student_teacher: 2 }
  has_many :enrollments
  has_many :teachers, through: :enrollments
  has_many :favorite_teachers, -> { where(enrollments: { favorite: true }) }, through: :enrollments, source: :teacher
end
