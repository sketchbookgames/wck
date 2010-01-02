﻿package misc {
	
	import flash.utils.*;
	import misc.*;
	
	/**
	 * A Dictionary that allows you to have a hierarchy of keys with values at the end of each branch. It mimics this functionality:
	 *
	 * var d = new Dictionary();
	 * d['key1'] = new Dictionary();
	 * d['key1']['key2'] = value;
	 * d['key1']['key3'] = other value;
	 *
	 * This becomes cumbersome because you have to manually create and destroy dictionaries. This class does it automatically.
	 * Use when you need to index values by multiple keys, rather than one key.
	 */
	public class DictionaryTree extends Dictionary {
	
		public var storage:Dictionary = new Dictionary();
		
		/**
		 * Store a value in the dictionary hierarchy. Call like so:
		 * store(['key1', 'key2', 'key3'], value);
		 */
		public function store(keys:Array, val:*):void {
			var k:* = keys.shift();
			if(keys.length == 0) {
				storage[k] = val;
			}
			else {
				var d:DictionaryTree = storage[k] as DictionaryTree;
				if(!d) {
					d = storage[k] = new DictionaryTree();
				}
				d.store(keys, val);
			}
		}
		
		/**
		 * Get a value from the dictionary tree. Call like so:
		 * retrieve('key1', 'key2', 'key3');
		 * If the value doesn't exist, or if one of the keys doesn't exist, returns undefined.
		 */
		public function retrieve(keys:Array):* {
			var k:* = keys.shift();
			if(keys.length == 0) {
				return storage[k];
			}
			else {
				var d:DictionaryTree = storage[k] as DictionaryTree;
				if(!d) {
					return undefined;
				}
				return d.retrieve(keys);
			}
		}
		
		/**
		 * Removes a value from the dictionary tree. Call like so:
		 * remove('key1', 'key2', 'key3', value);
		 * If this results in empty dictionaries anywhere in the hierarchy, they are removed. Can also destroy an entire branch like so:
		 * remove('key1', 'key2');
		 */
		public function remove(keys:Array):void {
			var k:* = keys.shift();
			var d:DictionaryTree = storage[k] as DictionaryTree;
			if(keys.length == 0) {
				if(d) {
					d.flush();
				}
				delete storage[k];
			}
			else {
				if(d) {
					d.remove(keys);
					if(d.isEmpty()) {
						delete d[k];
					}
				}
			}
		}
		
		/**
		 * Is it empty?
		 */
		public function isEmpty():Boolean {
			return Util.dictionaryIsEmpty(storage);
		}
		
		/**
		 * Reset the DictionaryTree.
		 */
		public function flush():void {
			for(var k:* in storage) {
				var d = storage[k] as DictionaryTree;
				if(d) {
					d.flush();
				}
				delete storage[k];
			}
		}
		
		/**
		 * Get all the values as a flat list.
		 */
		public function get values():Array {
			var vals:Array = [];
			forEach(function(k:Array, v:*):void {
				vals.push(v);
			});
			return vals;
		}
		
		/**
		 * For everything stored, calls a function with the signature:
		 * function(keys:Array, val:Value):void
		 * where keys are all the dictionary keys from root to the value, and value is the value stored.
		 */
		public function forEach(callback:Function, thisObject:* = null):void {
			_forEach(callback, filter, thisObject, []);
		}
		
		public function _forEach(callback:Function, filt:Function, thisObject:*, keys:Array):void {
			for(var k:* in storage) {
				keys.push(k);
				var d:DictionaryTree = storage[k] as DictionaryTree;
				if(d) {
					d._forEach(callback, filt, thisObject, keys);
				}
				else {
					if(filt(storage[k])) {
						callback.apply(thisObject, [keys.concat(), storage[k]]);
					}
				}
				keys.pop();
			}
		}
		
		/**
		 * Filter can be overridden to ignore certain objects when calling "values" or "forEach".
		 */
		public function filter(o:*):Boolean {
			return true;
		}
	}
}