-- Stored procedure for building the Nested Set from adjacency list.

DELIMITER ;;
CREATE DEFINER=`spf_root`@`%` PROCEDURE `build_nested_hierarchy`()
BEGIN
DECLARE counter INT;
DECLARE max_counter INT;
DECLARE current_top INT;

SET counter = 2;
SET max_counter = 2 * (SELECT COUNT(*) FROM catalog_tree_nodes);
SET current_top = 1;

INSERT INTO catalog_tree (stack_top, id , name, parent_id, hierarchy_level, lft, rgt)
SELECT 1, id, name, parent_id, hierarchy_level, 1, NULL
  FROM catalog_tree_nodes
 WHERE parent_id = 0;

DELETE FROM catalog_tree_nodes
 WHERE parent_id = 0;
	
WHILE counter <= (max_counter - 2) DO
	select @count := count(*) FROM catalog_tree AS CT, catalog_tree_nodes AS CTN WHERE CT.id = CTN.parent_id AND CT.stack_top = current_top;
	IF @count <= 0 THEN
		    UPDATE catalog_tree
          	SET rgt = counter,
            stack_top = -stack_top -- pops the stack
        	WHERE stack_top = current_top;
    	   	SET counter = counter + 1;
	       	SET current_top = current_top - 1;
	ELSE
			INSERT INTO catalog_tree (stack_top, id , name, parent_id, hierarchy_level, lft, rgt)
       		SELECT (current_top + 1), CTN.id, CTN.name, CTN.parent_id, CTN.hierarchy_level, counter, NULL
         	FROM catalog_tree AS CT, catalog_tree_nodes AS CTN
        	WHERE CT.id = CTN.parent_id
          	AND CT.stack_top = current_top
          	LIMIT 1;

        	DELETE FROM catalog_tree_nodes
         	WHERE id = (SELECT id
                        FROM catalog_tree
                       WHERE stack_top = current_top + 1);

        	SET counter = counter + 1;
        	SET current_top = current_top + 1;
	END IF;
END WHILE;
END;;
DELIMITER ;
