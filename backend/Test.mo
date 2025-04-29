import Principal "mo:base/Principal";
import Blob "mo:base/Blob";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Trie "mo:base/Trie";
import OrderBook "./OrderBook";

actor Test {
    // Aliases for order types and KLine data
    type OrderSide = OrderBook.OrderSide;
    type OrderType = OrderBook.OrderType;
    type OrderPrice = OrderBook.OrderPrice;
    type Tick = OrderBook.Tick;
    type OrderFilled = OrderBook.OrderFilled;
    type KBar = OrderBook.KBar;
    type KInterval = OrderBook.KInterval;
    type KLines = OrderBook.KLines;

    // Stable state: orderbook + chart data
    private stable var ic_orderBook: OrderBook.OrderBook = OrderBook.create();
    private stable var klines: KLines = OrderBook.createK(); // <-- ✅ charting data

    /// MAIN TRADE FUNCTION
    public shared func trade(
        txid: Blob,
        side: OrderSide,
        quantity: Nat,
        price: Nat,
        orderType: OrderType,
        unitSize: Nat
    ) : async Result.Result<[OrderFilled], Text> {
        let incoming: OrderPrice = switch side {
            case (#Buy) { { quantity = #Buy((quantity, quantity * price / unitSize)); price = price } };
            case (#Sell) { { quantity = #Sell(quantity); price = price } };
        };

        let result = OrderBook.trade(ic_orderBook, txid, incoming, orderType, unitSize);

        // Save updated book
        ic_orderBook := result.ob;

        // Save K-line (chart) updates
        klines := OrderBook.putBatch(klines, result.filled, unitSize);

        return #ok(result.filled); // ✅ Now returns all filled trades
    };

    /// Top-of-book prices
    public query func level1() : async Tick {
        return OrderBook.level1(ic_orderBook);
    };

    /// Full orderbook depth (useful for UI)
    public query func depth(depth: ?Nat) : async {
        ask: [OrderBook.PriceResponse];
        bid: [OrderBook.PriceResponse];
    } {
        return OrderBook.depth(ic_orderBook, depth);
    };

    /// Clear the orderbook (admin-only)
    public shared func clearOrderBook() : async () {
        ic_orderBook := OrderBook.clear(ic_orderBook);
    };

    /// Check if specific order exists
    public query func inOrderBook(txid: Blob) : async Bool {
        return OrderBook.inOrderBook(ic_orderBook, txid);
    };

    /// Get specific order
    public query func getOrder(txid: Blob, side: ?OrderSide) : async ?OrderPrice {
        return OrderBook.get(ic_orderBook, txid, side);
    };

    /// Remove an order manually
    public shared func removeOrder(txid: Blob, side: ?OrderSide) : async () {
        ic_orderBook := OrderBook.remove(ic_orderBook, txid, side);
    };

    /// 📊 Return K-line chart data for selected interval
    public query func getK(interval: KInterval) : async [KBar] {
        return OrderBook.getK(klines, interval);
    };
};
