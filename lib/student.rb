require_relative "../config/environment.rb"

class Student

  attr_accessor :name,:grade
  attr_reader :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(id=nil,name,grade)
    @id=id  
    @name=name
    @grade=grade
  end

  def self.create_table
    sql = <<-SQL
    create table if not exists students(
      id INTEGER primary key,
      name text,
      grade number
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    drop table if exists students
    SQL
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
      insert into students(name, grade) values(?, ?)
      SQL
      DB[:conn].execute(sql,self.name,self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name,grade)
    new_student = Student.new(name,grade)
    new_student.save
  end

  def self.new_from_db(row)
      name=row[1]
      grade=row[2]
      id=row[0]
      self.new(id,name,grade)
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
      SQL
  
      DB[:conn].execute(sql,name).map {|row| self.new_from_db(row)}.first
    end

    def update
      sql = <<-SQL
      update students set name = ?, grade=? where id=?
      SQL
      DB[:conn].execute(sql,self.name,self.grade,self.id)
    end


end
