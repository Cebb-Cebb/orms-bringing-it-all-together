class Dog

    attr_accessor  :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id= id 
        @name = name
        @breed = breed
    end 

    def self.create_table
        sql =  <<-SQL 
        CREATE TABLE IF NOT EXISTS dogs (
          id INTEGER PRIMARY KEY, 
          name TEXT, 
          breed INTEGER
          )
          SQL
        DB[:conn].execute(sql)      
    end
    
    def self.drop_table
        sql =  <<-SQL 
        DROP TABLE dogs;
        SQL
        DB[:conn].execute(sql)
    end 

    def save
        if self.id # updates a record if called on an object that is already persisted
            self.update
          else 
          sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
          SQL
      
          DB[:conn].execute(sql, self.name, self.breed)
            # binding.pry 
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end 
        self 
    end 

    def self.create(hash)
        dog = Dog.new(hash)
        dog.save 
    end 
    
    def self.new_from_db(row)
        # binding.pry 
        id = row[0]
        name = row[1]
        breed = row[2]
        dog  = Dog.new(id: id, name: name, breed: breed)
    end 

    def self.find_by_id(id)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
        LIMIT 1
        SQL
        
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
        # binding.pry 
    end 

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        AND breed = ?
        LIMIT 1
        SQL
        
        dog = DB[:conn].execute(sql, name, breed)

        if !dog.empty?
            d = dog[0]
            dog = Dog.new(id: d[0], name: d[1], breed: d[2])
        else
            dog = self.create(name: name, breed: breed)
        end 
        dog 
        # binding.pry 
    end 



    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end 

    def update 
        sql = "UPDATE dogs SET name = ?, breed = ? 
               WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 


end  