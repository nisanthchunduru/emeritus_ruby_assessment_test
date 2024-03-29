class User < ApplicationRecord
  has_many :enrollments
  has_many :programs, through: :enrollments
  has_many :teachers, through: :enrollments
  has_many :favorite_teachers, -> { where(enrollments: { favorite: true }) }, through: :enrollments, source: :teacher

  def taught_programs
    Enrollment.where(teacher: self)
  end

  def classmates
    User
      .joins(:programs)
      .where(programs: programs)
      .where.not(id: self.id)
  end

  enum kind: { student: 0, teacher: 1, student_teacher: 2 }

  validate :validate_kind_on_update, on: :update

  def validate_kind_on_update
    if changed_to_student? && was_teacher? && teaches_programs_currently?
      errors.add(:kind, "Kind can not be student because is teaching in at least one program")
    end
  end

  def teaches_programs_currently?
    taught_programs.exists?
  end

  private

  def was_teacher?
    kind_was == "teacher"
  end

  def changed_to_student?
    kind == "student"
  end
end
