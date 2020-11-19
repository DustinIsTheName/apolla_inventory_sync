class OrderController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:receive, :refund]

  def receive
    puts params

    order = Order.find_by_shopify_id(params["id"])
    tag_order = false

    unless order
      for line_item in params["line_items"]
        if line_item["title"].include? "(Kit)"
          begin
            kit_product = ShopifyAPI::Product.find(line_item["product_id"])
            kit_variant = ShopifyAPI::Variant.find(line_item["variant_id"])

            check_credit

            counterpart_title = kit_product.title.gsub("(Kit)",'').strip
            main_product = ShopifyAPI::Product.find(:all, params: {title: counterpart_title}).select{|p| p.title == counterpart_title}&.first

            puts Colorize.magenta(main_product.title)

            variant = main_product.variants.select{|v| v.title == kit_variant.title}.first
            inventory_item_params = { inventory_item_ids: variant.inventory_item_id }
            inventory_levels = ShopifyAPI::InventoryLevel.find(:all, params: inventory_item_params)

            puts Colorize.magenta(variant.id)

            inventory_level = inventory_levels.select{|l| l.location_id == 490635287}.first

            if inventory_level.adjust(line_item["quantity"].to_i * -1)
              puts Colorize.green("Changed inventory by #{line_item["quantity"]}")
            else
              puts Colorize.red("error setting quantity")
              puts inventory_level
            end
          rescue Exception => e
            puts Colorize.red(e)
          end
        else
          puts Colorize.cyan("Not a kit item")
        end

        if line_item["title"].downcase.include? "gift"
          tag_order = true
          puts Colorize.green("Is a gift item")
        else
          puts Colorize.cyan("Not a gift item")
        end

        check_credit
      end

      if tag_order
        shopify_order = ShopifyAPI::Order.find params["id"]
        shopify_order.tags << ", GIFT"
        if shopify_order.save
          puts Colorize.green("added tag to order")
        end
      end

      order = Order.new
      order.shopify_id = params["id"]
      order.save
    else
      puts Colorize.cyan("Order is repeated")
    end

    head :ok
  end 

  def refund
    puts params

    refund = Refund.find_by_shopify_id(params["id"])

    unless refund
      for refund_line_item in params["refund_line_items"]
        if refund_line_item["line_item"]["title"].include? "(Kit)"
          line_item = refund_line_item["line_item"]

          begin
            kit_product = ShopifyAPI::Product.find(line_item["product_id"])
            kit_variant = ShopifyAPI::Variant.find(line_item["variant_id"])

            counterpart_title = kit_product.title.gsub("(Kit)",'').strip
            main_product = ShopifyAPI::Product.find(:all, params: {title: counterpart_title}).select{|p| p.title == counterpart_title}&.first

            puts Colorize.magenta(main_product.title)

            variant = main_product.variants.select{|v| v.title == kit_variant.title}.first
            inventory_item_params = { inventory_item_ids: variant.inventory_item_id }
            inventory_levels = ShopifyAPI::InventoryLevel.find(:all, params: inventory_item_params)

            puts Colorize.magenta(variant.id)

            if inventory_levels[0].adjust(line_item["quantity"].to_i)
              puts Colorize.green("Restocked inventory by #{line_item["quantity"]}")
            else
              puts Colorize.red("error setting quantity")
              puts inventory_levels[0]
            end
          rescue Exception => e
            puts Colorize.red(e)
          end
        else
          puts Colorize.cyan("Not a kit item")
        end
      end

      refund = Refund.new
      refund.shopify_id = params["id"]
      refund.save
    else
      puts Colorize.cyan("Refund is repeated")
    end

    head :ok
  end

  def check_credit
    if ShopifyAPI.credit_left < 5
      puts Colorize.white("sleeping for 5...")
      sleep 5
    end
  end

end