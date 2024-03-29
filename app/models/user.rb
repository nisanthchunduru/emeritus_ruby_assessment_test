class User < ApplicationRecord
  has_many :enrollments
  has_many :programs, through: :enrollments
  has_many :teachers, through: :enrollments
  has_many :favorite_teachers, -> { where(enrollments: { favorite: true }) }, through: :enrollments, source: :teacher

  def classmates
    User
      .joins(:programs)
      .where(programs: programs)
      .where.not(id: self.id)
  end

  enum kind: { student: 0, teacher: 1, student_teacher: 2 }

  validate :validate_kind_on_update, on: :update

  def studies_programs?
    programs.exists?
  end

  def teaches_programs?
    Enrollment.where(teacher: self).exists?
  end

  private

  def validate_kind_on_update
    if changed_to_student? && was_teacher? && teaches_programs?
      errors.add(:kind, "Kind can not be student because is teaching in at least one program")
    end

    if changed_to_teacher? && was_student? && studies_programs?
      errors.add(:kind, "Kind can not be teacher because is studying in at least one program")
    end
  end

  def changed_to_student?
    kind == "student"
  end

  def changed_to_teacher?
    kind == "teacher"
  end

  def was_teacher?
    kind_was == "teacher"
  end

  def was_student?
    kind_was == "student"
  end
end
