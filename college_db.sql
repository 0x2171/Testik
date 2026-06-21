DROP DATABASE IF EXISTS college_db;
CREATE DATABASE IF NOT EXISTS college_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE college_db;

-- =====================================================
-- ТАБЛИЦЫ
-- =====================================================

CREATE TABLE IF NOT EXISTS `groups` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `subjects` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `users` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    user_type ENUM('student', 'parent', 'teacher', 'admin') NOT NULL,
    group_id INT NULL,
    record_book_number VARCHAR(20) NULL DEFAULT NULL,
    linked_student_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES `groups`(id) ON DELETE SET NULL,
    FOREIGN KEY (linked_student_id) REFERENCES `users`(id) ON DELETE SET NULL,
    INDEX idx_login (login),
    INDEX idx_user_type (user_type),
    INDEX idx_group (group_id),
    INDEX idx_record_book (record_book_number),
    INDEX idx_linked_student (linked_student_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `grades` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    grade VARCHAR(5) NOT NULL,
    date DATE NOT NULL,
    comment TEXT NULL,
    teacher_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES `users`(id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES `subjects`(id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES `users`(id) ON DELETE SET NULL,
    INDEX idx_student (student_id),
    INDEX idx_subject (subject_id),
    INDEX idx_date (date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `attendance` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('present', 'absent', 'late') NOT NULL,
    comment TEXT NULL,
    FOREIGN KEY (student_id) REFERENCES `users`(id) ON DELETE CASCADE,
    UNIQUE KEY unique_attendance (student_id, date),
    INDEX idx_student_date (student_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- ДОБАВЛЯЕМ НЕДОСТАЮЩИЕ КОЛОНКИ (для обновления старых БД)
-- =====================================================

SET @dbname = DATABASE();
SET @tablename = 'users';

-- Колонка record_book_number
SET @columnname = 'record_book_number';
SET @preparedStatement = (SELECT IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname) = 0,
    CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(20) NULL DEFAULT NULL AFTER group_id;'),
    'SELECT 1;'
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Колонка linked_student_id
SET @columnname2 = 'linked_student_id';
SET @preparedStatement2 = (SELECT IF(
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = @dbname AND TABLE_NAME = @tablename AND COLUMN_NAME = @columnname2) = 0,
    CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname2, ' INT NULL DEFAULT NULL AFTER ', @columnname, ';'),
    'SELECT 1;'
));
PREPARE stmt2 FROM @preparedStatement2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- Внешний ключ на linked_student_id
SET @fkname = 'fk_users_linked_student';
SET @preparedStatement3 = (SELECT IF(
    (SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS 
     WHERE CONSTRAINT_SCHEMA = @dbname AND TABLE_NAME = @tablename AND CONSTRAINT_NAME = @fkname) = 0,
    CONCAT('ALTER TABLE ', @tablename, ' ADD CONSTRAINT ', @fkname, 
           ' FOREIGN KEY (linked_student_id) REFERENCES users(id) ON DELETE SET NULL;'),
    'SELECT 1;'
));
PREPARE stmt3 FROM @preparedStatement3;
EXECUTE stmt3;
DEALLOCATE PREPARE stmt3;

-- =====================================================
-- ДАННЫЕ
-- =====================================================

INSERT IGNORE INTO `groups` (name) VALUES 
('ИТ-21'), ('ИТ-22'), ('ИТ-23'), ('Экономика-21'), ('Экономика-22');

INSERT IGNORE INTO `subjects` (name) VALUES 
('Математика'), ('Программирование'), ('Базы данных'), ('Физика'), ('История'),
('Английский язык'), ('Экономика'), ('Право'), ('Философия'), ('Маркетинг');

INSERT IGNORE INTO `users` (login, password, full_name, user_type, group_id, record_book_number) VALUES
('student1', '12345', 'Иванов Иван Петрович', 'student', 1, '123456'),
('student2', '12345', 'Петров Пётр Сергеевич', 'student', 1, '123457'),
('student3', '12345', 'Сидоров Сидор Иванович', 'student', 2, '123458'),
('student4', '12345', 'Кузнецов Алексей Дмитриевич', 'student', 2, '123459'),
('student5', '12345', 'Смирнова Анна Владимировна', 'student', 3, '123460'),
('student6', '12345', 'Попов Дмитрий Николаевич', 'student', 3, '123461'),
('student7', '12345', 'Васильева Екатерина Андреевна', 'student', 4, '123462'),
('student8', '12345', 'Михайлов Максим Игоревич', 'student', 4, '123463'),
('student9', '12345', 'Фёдорова Ольга Сергеевна', 'student', 5, '123464'),
('student10', '12345', 'Новиков Артём Павлович', 'student', 5, '123465');

INSERT IGNORE INTO `users` (login, password, full_name, user_type, group_id) VALUES
('parent1', '12345', 'Иванова Мария Ивановна', 'parent', 1),
('parent2', '12345', 'Петрова Елена Петровна', 'parent', 2),
('parent3', '12345', 'Сидорова Наталья Сидоровна', 'parent', 3),
('teacher1', '12345', 'Смирнов Виктор Александрович', 'teacher', NULL),
('teacher2', '12345', 'Козлова Наталья Михайловна', 'teacher', NULL),
('teacher3', '12345', 'Волков Сергей Петрович', 'teacher', NULL),
('admin', 'admin123', 'Администратор Системы', 'admin', NULL);

-- Привязываем родителей к студентам (исправлено: без подзапроса)
UPDATE users AS parent
JOIN users AS student ON student.login = 'student1'
SET parent.linked_student_id = student.id
WHERE parent.login = 'parent1';

UPDATE users AS parent
JOIN users AS student ON student.login = 'student2'
SET parent.linked_student_id = student.id
WHERE parent.login = 'parent2';

UPDATE users AS parent
JOIN users AS student ON student.login = 'student3'
SET parent.linked_student_id = student.id
WHERE parent.login = 'parent3';

INSERT IGNORE INTO `grades` (student_id, subject_id, grade, date, comment, teacher_id) VALUES
(1, 1, '5', '2024-01-15', 'Отличная работа на контрольной', 11),
(1, 2, '4', '2024-01-16', 'Хорошо, но есть недочёты', 11),
(1, 3, '5', '2024-01-17', 'Превосходное понимание темы', 12),
(1, 1, '4', '2024-01-22', 'Активная работа на семинаре', 11),
(1, 2, '5', '2024-01-23', 'Отличный проект', 11),
(2, 1, '4', '2024-01-15', 'Хорошо', 11),
(2, 2, '3', '2024-01-16', 'Нужно подтянуть теорию', 11),
(2, 4, '4', '2024-01-18', 'Удовлетворительно', 12),
(2, 1, '5', '2024-01-22', 'Улучшил результат', 11),
(3, 1, '5', '2024-01-15', 'Отлично', 11),
(3, 3, '4', '2024-01-17', 'Хорошо', 12),
(3, 2, '5', '2024-01-23', 'Блестяще!', 11),
(4, 2, '5', '2024-01-16', 'Превосходно', 11),
(4, 3, '4', '2024-01-17', 'Хорошо', 12),
(4, 1, '3', '2024-01-22', 'Требуется доработка', 11),
(5, 1, '4', '2024-01-15', 'Хорошо', 11),
(5, 4, '5', '2024-01-18', 'Отличная работа', 12),
(5, 6, '5', '2024-01-19', 'Превосходный английский', 13);

INSERT IGNORE INTO `attendance` (student_id, date, status, comment) VALUES
(1, '2024-01-15', 'present', NULL),
(1, '2024-01-16', 'present', NULL),
(1, '2024-01-17', 'late', 'Опоздал на 10 минут'),
(2, '2024-01-15', 'present', NULL),
(2, '2024-01-16', 'absent', 'По болезни'),
(3, '2024-01-15', 'present', NULL),
(3, '2024-01-17', 'present', NULL),
(4, '2024-01-16', 'present', NULL),
(5, '2024-01-15', 'present', NULL),
(5, '2024-01-18', 'present', NULL);

-- =====================================================
-- ПРЕДСТАВЛЕНИЯ
-- =====================================================

CREATE OR REPLACE VIEW v_students AS
SELECT 
    u.id,
    u.login,
    u.full_name,
    u.record_book_number,
    g.name AS group_name,
    u.created_at
FROM `users` u
LEFT JOIN `groups` g ON u.group_id = g.id
WHERE u.user_type = 'student'
ORDER BY g.name, u.full_name;

CREATE OR REPLACE VIEW v_diary AS
SELECT 
    gr.id AS grade_id,
    u.full_name AS student_name,
    s.name AS subject_name,
    gr.grade,
    gr.date,
    gr.comment,
    t.full_name AS teacher_name
FROM `grades` gr
JOIN `users` u ON gr.student_id = u.id
JOIN `subjects` s ON gr.subject_id = s.id
LEFT JOIN `users` t ON gr.teacher_id = t.id
ORDER BY gr.date DESC, u.full_name;

CREATE OR REPLACE VIEW v_average_grades AS
SELECT 
    u.id AS student_id,
    u.full_name,
    u.record_book_number,
    g.name AS group_name,
    ROUND(AVG(CASE 
        WHEN gr.grade IN ('2','3','4','5') THEN CAST(gr.grade AS UNSIGNED)
        ELSE NULL 
    END), 2) AS average_grade,
    COUNT(gr.id) AS grades_count
FROM `users` u
LEFT JOIN `groups` g ON u.group_id = g.id
LEFT JOIN `grades` gr ON u.id = gr.student_id 
    AND gr.grade IN ('2','3','4','5')
WHERE u.user_type = 'student'
GROUP BY u.id, u.full_name, u.record_book_number, g.name;

-- =====================================================
-- ПРОЦЕДУРЫ
-- =====================================================

DROP PROCEDURE IF EXISTS sp_search_students;
DROP PROCEDURE IF EXISTS sp_get_student_grades;

DELIMITER //

CREATE PROCEDURE sp_search_students(IN search_term VARCHAR(100), IN group_filter INT)
BEGIN
    SELECT 
        u.id,
        u.login,
        u.full_name,
        u.record_book_number,
        g.name AS group_name,
        u.user_type
    FROM `users` u
    LEFT JOIN `groups` g ON u.group_id = g.id
    WHERE u.user_type = 'student'
      AND (
          search_term IS NULL OR search_term = '' OR
          u.full_name LIKE CONCAT('%', search_term, '%') OR
          u.login LIKE CONCAT('%', search_term, '%') OR
          u.record_book_number LIKE CONCAT('%', search_term, '%')
      )
      AND (
          group_filter IS NULL OR group_filter = 0 OR
          u.group_id = group_filter
      )
    ORDER BY g.name, u.full_name;
END //

CREATE PROCEDURE sp_get_student_grades(IN p_student_id INT, IN p_subject_id INT)
BEGIN
    SELECT 
        gr.id,
        gr.date,
        s.name AS subject_name,
        gr.grade,
        gr.comment,
        u.full_name AS teacher_name
    FROM `grades` gr
    JOIN `subjects` s ON gr.subject_id = s.id
    LEFT JOIN `users` u ON gr.teacher_id = u.id
    WHERE gr.student_id = p_student_id
      AND (p_subject_id IS NULL OR p_subject_id = 0 OR gr.subject_id = p_subject_id)
    ORDER BY gr.date DESC;
END //

DELIMITER ;