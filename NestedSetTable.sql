-- Target table holding the nested set hierarchy.

CREATE TABLE `catalog_tree` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `parent_id` int(11) DEFAULT NULL,
  `hierarchy_level` int(11) DEFAULT NULL,
  `lft` int(11) NOT NULL,
  `rgt` int(11) DEFAULT NULL,
  `stack_top` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2611 DEFAULT CHARSET=latin1;
