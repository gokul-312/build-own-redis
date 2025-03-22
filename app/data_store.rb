class DataStore
  attr_accessor :store

  EXPIRE_KEY_IN_SEC = 60

  def initialize
    @store = {}
  end

  def set(key, value)
    store[key] = { value: value, modified_at: Time.now.utc + EXPIRE_KEY_IN_SEC }
  end

  def get(key)
    val = value(key)
    return unless val

    delete(key) && return if expired?(key)

    val
  end

  def value(key)
    store.dig(key, :value)
  end

  def modified_at(key)
    store.dig(key, :modified_at)
  end

  def expired?(key)
    modified_at(key).past?
  end

  def delete(key)
    store.delete key
  end
end


# including past method for ruby/time class
class Time 
  def past?
    self < Time.now.utc
  end
end