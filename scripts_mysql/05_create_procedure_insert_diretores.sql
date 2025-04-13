USE demo;

DELIMITER $$

CREATE PROCEDURE sp_insert_diretores(IN qtd_loop INT)
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= qtd_loop DO
        INSERT INTO diretores (nome) VALUES (CONCAT('DIRETOR ', i));
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;