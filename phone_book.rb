# frozen_string_literal: true

# 1. Znajdz kontakt
# -> 1. Usuń
# -> 2. Powrót
# 2. Dodaj kontakt
# 3. Pokaz wszystkie kontakty
# 4. Wyjdz

require './data'

module Contacts
  class Book
    def initialize
      @function = nil
      @current_contact = nil
      @db = Data.new
      @contacts = @db.get("contacts", [])
    end

    def start
      if @function.nil?
        show_menu
      else
        case @function
        when 1 then find_contact
        when 2 then add_contact
        when 3 then show_all_contacts
        else
          exit
        end
      end
    end

    def find_contact_form
      puts "\nKogo szukasz? Podaj nazwę lub telefon osoby."
      searching_value = gets.strip
      contact = @contacts.find { |el| el["name"] == searching_value || el["number"] == searching_value }
      if contact
        @current_contact = contact
        find_contact
      else
        message("NIE MA TAKIEGO NUMERU!")
        select_option(nil)
      end
    end

    def show_contact_menu
      puts " Znaleziony kontakt to:"
      puts "#{@current_contact["name"]} (#{@current_contact["number"]})"
      puts "1. Powrót"
      puts "2. Usuń"

      opcja = Integer(gets)

      if (1..2).include?(opcja)
        if opcja == 1
          @current_contact = nil
          select_option(nil)
        else
          remove_contact
        end
      else
        message("Nie ma takiej opcji!")
        show_contact_menu
      end
    end

    def remove_contact
      @contacts -= [@current_contact]
      @db.set("contacts", @contacts)
      message("USUNIĘTO!")
      select_option(nil)
    end

    def find_contact
      if @current_contact.nil?
        find_contact_form
      else
        show_contact_menu
      end
    end

    def add_contact
      puts "Podaj nazwe kontaktu:"
      nazwa = gets.strip
      puts "Podaj numer telefonu:"
      telefon = gets.strip
      puts "Czy chcesz dodać taki kontakt (t/n):"
      puts "#{nazwa} (#{telefon})"
      decyzja = gets.strip
      if decyzja.include?("t")
        @contacts << { 'name' => nazwa, 'number' => telefon }
        @db.set("contacts", @contacts)
        message("DODANO!")
      else
        add_contact
      end

      select_option(nil)
    end

    def show_all_contacts
      puts "Oto twoje kontakty:\n"
      @contacts.each do |contact|
        puts "#{contact["name"]} (#{contact["number"]})"
      end
      puts "\n"
      select_option(nil)
    end

    def exit
      puts "Dziękujemy za korzystanie z naszych usług! BQ-TECH.pl"
    end

    def show_menu
      puts "Wybierz dostępną opcję:"
      puts "1. Znajdź kontakt"
      puts "2. Dodaj kontakt"
      puts "3. Pokaż wszystkie kontakty"
      puts "4. Wyjdź"

      opcja = Integer(gets)
      unless (1..4).include?(opcja)
        message("PODANO ZŁĄ OPCJĘ!")
        return show_menu
      end

      select_option(opcja)
    end

    private

    def select_option(option)
      @function = option
      start
    end

    def message(text)
      puts "\n#{text}\n\n"
    end
  end
end

program = Contacts::Book.new
program.start
