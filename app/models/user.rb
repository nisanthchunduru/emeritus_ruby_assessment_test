class User < ApplicationRecord
  has_many :enrollments
  has_many :programs, through: :enrollments
  has_many :teachers, through: :enrollments
  has_many :favorite_teachers, -> { where(enrollments: { favorite: true }) }, through: :enrollments, source: :teacher

  enum kind: { student: 0, teacher: 1, student_teacher: 2 }

  def classmates
    User
      .joins(:programs)
      .where(programs: programs)
      .where.not(id: self.id)
  end
end
