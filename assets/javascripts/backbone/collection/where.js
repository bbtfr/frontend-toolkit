// Return models with matching attributes. Useful for simple cases of
// `filter`.
Backbone.Collection.prototype.where = function(attrs, first) {
  if (_.isEmpty(attrs)) return first ? void 0 : [];
  return this[first ? 'find' : 'filter'](function(model) {
    for (var key in attrs) {
      var filter = attrs[key],
        attr = model.get(key);
      if (_.isFunction(filter) && filter(attr)) continue;
      if (_.isArray(filter) && filter.indexOf(attr) >= 0) continue;
      if (filter === attr) continue;
      return false;
    }
    return true;
  });
};
