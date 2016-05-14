-- Stored procedure for building the Nested Set from adjacency list.

DELIMITER ;;
CREATE DEFINER=`test_user`@`%` PROCEDURE `build_nested_hierarchy`()
BEGIN
DECLARE counter INT;
DECLARE max_counter INT;
DECLARE current_top INT;

SET counter = 2;
SET max_counter = 2 * (SELECT COUNT(*) FROM tree_nodes);
SET current_top = 1;

INSERT INTO tree (stack_top, id , name, parent_id, level, lft, rgt)
SELECT 1, id, name, parent_id, level, 1, NULL
  FROM tree_nodes
 WHERE parent_id = 0;

DELETE FROM tree_nodes
 WHERE parent_id = 0;
	
WHILE counter <= (max_counter - 2) DO
	select @count := count(*) FROM tree AS CT, tree_nodes AS TN WHERE CT.id = TN.parent_id AND CT.stack_top = current_top;
	IF @count <= 0 THEN
		    UPDATE tree
          	SET rgt = counter,
            stack_top = -stack_top -- pops the stack
        	WHERE stack_top = current_top;
    	   	SET counter = counter + 1;
	       	SET current_top = current_top - 1;
	ELSE
			INSERT INTO tree (stack_top, id , name, parent_id, level, lft, rgt)
       		SELECT (current_top + 1), TN.id, TN.name, TN.parent_id, TN.level, counter, NULL
         	FROM tree AS CT, tree_nodes AS TN
        	WHERE CT.id = TN.parent_id
          	AND CT.stack_top = current_top
          	LIMIT 1;

        	DELETE FROM tree_nodes
         	WHERE id = (SELECT id
                        FROM tree
                       WHERE stack_top = current_top + 1);

        	SET counter = counter + 1;
        	SET current_top = current_top + 1;
	END IF;
END WHILE;
END;;
DELIMITER ;
