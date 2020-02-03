# Imitacja bazy danych z bardzo prostym interfejsem
# Z zapisem danych do pliku, z mozliwoscią wznowienia pracy
# Struktura danych w bazie powinna byc dowolna
#
# API:
# a = Data.new -> powinno stworzyc nowego klienta bazy i załadować dane z dysku
# a.get("jakis.klucz.12") -> powinno zwrócić dane, zwróci KeyNotFoundError jeśli klucz nie istnieje
# a.get("jakis.klucz.12", "test") -> zwróci "test", jesli klucz nie istnieje
# a.set("jakis.klucz", dowolne_dane) -> powinno zapisać dane w bazie
# a.delete("jakiś.klucz")



require 'json'

class Data
  class NoDefaultValue; end
  class KeyNotFoundError < StandardError; end

  def initialize
    @data = {}
    load_data
  end

  def get(key, default_value = NoDefaultValue.new)
    raise KeyNotFoundError if default_value.is_a?(NoDefaultValue) && !key_exists?(key)
    return default_value unless key_exists?(key)

    element = @data
    key_to_a(key).each do |key|
      element = element[key]
    end
    element
  end

  def set(key, data)
    return ArgumentError if key =~ /\d/
    return ArgumentError unless data.respond_to?(:to_json)

    element = @data # {}
    key_to_a(key).each_with_index do |k, index|
      # if last
      if index == key_to_a(key).size - 1
        element[k] = data
      else
        element[k] ||= {}
        element[k] = {} unless element[k].is_a?(Hash)
        element = element[k]
      end
    end
    save_data
  end

  def delete(key)
    return ArgumentError if key =~ /\d/
    return KeyNotFoundError unless key_exists?(key)

    element = @data
    key_to_a(key).each_with_index do |k, index|
      if index == key_to_a(key).size - 1
        element.delete(k)
      else
        element = element[k]
      end
    end

    save_data
  end


  private

  # obsluga plikow
  def load_data
    return unless File.exist?("data.json")

    @data = JSON.parse(File.read("data.json"))
  end

  def save_data
    File.open("data.json", "w") { |file| file.puts(@data.to_json) }
  end

  def key_to_a(key)
    key.split('.').map do |el|
      Integer(el)
    rescue ArgumentError
      el
    end
  end

  def key_exists?(key)
    key_array = key_to_a(key)

    element = @data
    key_array.each do |key|
      if element.is_a?(Array)
        return false unless key.is_a?(Integer)
        return false if element[key].nil?
      elsif element.is_a?(Hash)
        return false if key.is_a?(Integer)
        return false unless element.keys.include?(key)
      end

      element = element[key]
    end

    true
  end
end
