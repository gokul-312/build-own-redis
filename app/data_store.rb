class DataStore
  attr_accessor :store

  EXPIRE_KEY_IN_SEC = 60

  def initialize
    @store = {}
    @lock = Mutex.new
  end

  def set(key, value)
    concurrent_hash { store[key] = { value: value } }
  end

  def get(key)
    val = value(key)
    return unless val

    delete(key) && return if expired?(expire_at(key))

    val
  end

  def ttl(key)
    return "No Expiry" unless (val = expire_at(key))

    val.to_i - Time.now.to_i
  end

  def set_expiry(key, seconds: nil, expire_at: nil)
    return "--Key Does Not Exists" unless store.key? key


    store[key][:expire_at] = expire_at || (Time.now.to_i + seconds.to_i)
    "OK"
  end

  private

  def value(key)
    concurrent_hash { store.dig(key, :value) }
  end

  def expire_at(key)
    concurrent_hash { store.dig(key, :expire_at) }
  end

  def expired?(expire_at)
    return false if expire_at.nil?

    expire_at.to_i < Time.now.to_i
  end

  def delete(key)
    concurrent_hash { store.delete(key) }
  end

  def concurrent_hash 
    @lock.synchronize { yield }
  end
end