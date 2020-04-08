class OrderController < ApplicationController

  skip_before_filter :verify_authenticity_token, :only => [:receive, :refund]

  def receive
    puts params

    order = Order.find_by_shopify_id(params["id"])

    unless order
      for line_item in params["line_items"]
        if line_item["title"].include? "(Kit)"
          begin
            counterpart_title = line_item["title"].gsub("(Kit)",'').strip
            main_product = ShopifyAPI::Product.find(:all, params: {title: counterpart_title}).select{|p| p.title == counterpart_title}&.first

            puts Colorize.magenta(main_product.title)

            variant = main_product.variants.select{|v| v.title == line_item["variant_title"]}.first
            inventory_item_params = { inventory_item_ids: variant.inventory_item_id }
            inventory_levels = ShopifyAPI::InventoryLevel.find(:all, params: inventory_item_params)

            puts Colorize.magenta(variant.id)

            if inventory_levels[0].adjust(line_item["quantity"].to_i * -1)
              puts Colorize.green("Changed inventory by #{line_item["quantity"]}")
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
            counterpart_title = line_item["title"].gsub("(Kit)",'').strip
            main_product = ShopifyAPI::Product.find(:all, params: {title: counterpart_title}).select{|p| p.title == counterpart_title}&.first

            puts Colorize.magenta(main_product.title)

            variant = main_product.variants.select{|v| v.title == line_item["variant_title"]}.first
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

end