def list_inventory(store)
  puts "-------------------------------------------------------------------"
  puts store.to_s
  puts "-------------------------------------------------------------------"
  puts "Current inventory:"
  puts ""
  store.inventory.each do |item|
    puts "\t#{item.name}: #{store.stock(item)} items"
  end
end
