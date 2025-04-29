import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface OrderPrice {
  'quantity' : { 'Buy' : [bigint, bigint] } |
    { 'Sell' : bigint },
  'price' : bigint,
}
export type OrderSide = { 'Buy' : null } |
  { 'Sell' : null };
export type OrderType = { 'FAK' : null } |
  { 'FOK' : null } |
  { 'LMT' : null } |
  { 'MKT' : null };
export interface PriceResponse { 'quantity' : bigint, 'price' : bigint }
export type Result = { 'ok' : null } |
  { 'err' : string };
export interface Tick { 'bestAsk' : PriceResponse, 'bestBid' : PriceResponse }
export interface _SERVICE {
  'clearOrderBook' : ActorMethod<[], undefined>,
  'depth' : ActorMethod<
    [[] | [bigint]],
    { 'ask' : Array<PriceResponse>, 'bid' : Array<PriceResponse> }
  >,
  'getOrder' : ActorMethod<
    [Uint8Array | number[], [] | [OrderSide]],
    [] | [OrderPrice]
  >,
  'inOrderBook' : ActorMethod<[Uint8Array | number[]], boolean>,
  'level1' : ActorMethod<[], Tick>,
  'removeOrder' : ActorMethod<
    [Uint8Array | number[], [] | [OrderSide]],
    undefined
  >,
  'trade' : ActorMethod<
    [Uint8Array | number[], OrderSide, bigint, bigint, OrderType, bigint],
    Result
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
