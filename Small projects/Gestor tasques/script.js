

document.addEventListener('DOMContentLoaded', function () {
    const taskForm = document.getElementById('task-form');
    const taskList = document.getElementById('task-list');
    const completedTaskList = document.getElementById('completed-task-list');
    const deleteCompletedButton = document.getElementById('delete-completed-button');
    const sortTasksButton = document.getElementById('sort-tasks-button');
    const saveTasksButton = document.getElementById('save-tasks-button');
    const currentDateElement = document.getElementById('current-date');
    const clockElement = document.getElementById('clock');
    const darkModeToggle = document.getElementById('dark-mode-toggle');


    // Cargar tareas desde el localStorage al cargar la página
    loadTasks();

    // Mostrar la fecha y el reloj
    showCurrentDate();
    showClock();
    setInterval(showClock, 1000);

    taskForm.addEventListener('submit', function (event) {
        event.preventDefault();

        const date = document.getElementById('date').value;
        const subject = document.getElementById('subject').value;
        const description = document.getElementById('description').value;

        const task = { date, subject, description, completed: false };
        addTaskToDOM(task); // Añadir la tarea al DOM
        taskForm.reset(); // Limpiar el formulario
    });

    deleteCompletedButton.addEventListener('click', function () {
        completedTaskList.innerHTML = ''; // Eliminar tareas completadas del DOM
    });

    sortTasksButton.addEventListener('click', sortTasksByDate);

    // Guardar tareas solo cuando se haga clic en "Guardar"
    saveTasksButton.addEventListener('click', function () {
        updateLocalStorage(); // Guardar todas las tareas en el localStorage
        alert('Tasques guardades correctament.'); // Mostrar mensaje de confirmación
    });

    function addTaskToDOM(task) {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${task.date}</td>
            <td>${task.subject}</td>
            <td>${task.description}</td>
            <td><button class="fet ${task.completed ? 'completed' : ''}">${task.completed ? '🔄' : '✅'}</button></td>
            <td><button class="editar">✏️</button></td>
            <td><button class="eliminar">❌</button></td>
        `;

        (task.completed ? completedTaskList : taskList).appendChild(row);

        // Botón de completar/marcar como pendiente
        row.querySelector('.fet').addEventListener('click', function () {
            if (task.completed) {
                // Si la tarea está completada, moverla a la tabla de pendientes
                task.completed = false;
                row.remove();
                taskList.appendChild(row);
                row.querySelector('.fet').textContent = '✅'; // Cambiar el emoji a ✅
                row.querySelector('.fet').classList.remove('completed'); // Quitar la clase 'completed'
            } else {
                // Si la tarea está pendiente, moverla a la tabla de completadas
                task.completed = true;
                row.remove();
                completedTaskList.appendChild(row);
                row.querySelector('.fet').textContent = '🔄'; // Cambiar el emoji a 🔄
                row.querySelector('.fet').classList.add('completed'); // Añadir la clase 'completed'
            }
        });

        // Botón de eliminar
        row.querySelector('.eliminar').addEventListener('click', function () {
            row.remove();
        });

        // Botón de editar
        row.querySelector('.editar').addEventListener('click', function () {
            openEditModal(task, row);
        });
    }

    function loadTasks() {
        const tasks = JSON.parse(localStorage.getItem('tasks')) || [];
        tasks.forEach(addTaskToDOM);
    }

    function updateLocalStorage() {
        const tasks = Array.from(document.querySelectorAll('#task-list tr, #completed-task-list tr')).map(row => ({
            date: row.cells[0].textContent,
            subject: row.cells[1].textContent,
            description: row.cells[2].textContent,
            completed: row.parentElement.id === 'completed-task-list'
        }));
        localStorage.setItem('tasks', JSON.stringify(tasks));
    }

    function showCurrentDate() {
        currentDateElement.textContent = new Date().toLocaleDateString('ca-ES', { year: 'numeric', month: 'long', day: 'numeric' });
    }

    function showClock() {
        const now = new Date();
        clockElement.textContent = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}:${now.getSeconds().toString().padStart(2, '0')}`;
    }

    function sortTasksByDate() {
        const tasks = Array.from(taskList.querySelectorAll('tr')).sort((a, b) => new Date(a.cells[0].textContent) - new Date(b.cells[0].textContent));
        taskList.innerHTML = '';
        tasks.forEach(task => taskList.appendChild(task));
    }

    if (localStorage.getItem('darkMode') === 'enabled') {
        document.documentElement.classList.add('dark-mode');
        darkModeToggle.textContent = '☀️ Mode Clar';
    }

    darkModeToggle.addEventListener('click', function () {
        document.documentElement.classList.toggle('dark-mode');
        localStorage.setItem('darkMode', document.documentElement.classList.contains('dark-mode') ? 'enabled' : 'disabled');
        darkModeToggle.textContent = document.documentElement.classList.contains('dark-mode') ? '☀️ Mode Clar' : '🌙 Mode Fosc';
    });

    function openEditModal(task, row) {
        const modal = document.getElementById('edit-modal');
        const editDate = document.getElementById('edit-date');
        const editSubject = document.getElementById('edit-subject');
        const editDescription = document.getElementById('edit-description');
        const editForm = document.getElementById('edit-task-form');

        editDate.value = task.date;
        editSubject.value = task.subject;
        editDescription.value = task.description;

        // Hacer visible el modal antes de la transición
        modal.style.display = 'block';

        // Forzar un reflow para que el navegador aplique el cambio de display antes de la transición
        void modal.offsetHeight;

        // Añadir la clase 'show' para activar la animación
        modal.classList.add('show');

        document.getElementById('close').addEventListener('click', () => {
            // Quitar la clase 'show' para iniciar la animación de salida
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none'; // Ocultar el modal después de la animación
            }, 300); // Ajusta el tiempo según la duración de la animación
        });

        editForm.onsubmit = function (event) {
            event.preventDefault();
            task.date = editDate.value;
            task.subject = editSubject.value;
            task.description = editDescription.value;
            row.cells[0].textContent = task.date;
            row.cells[1].textContent = task.subject;
            row.cells[2].textContent = task.description;

            // Quitar la clase 'show' para iniciar la animación de salida
            modal.classList.remove('show');
            setTimeout(() => {
                modal.style.display = 'none'; // Ocultar el modal después de la animación
            }, 300); // Ajusta el tiempo según la duración de la animación
        };
    }
    function exportTasks() {
        const tasks = JSON.parse(localStorage.getItem('tasks')) || [];
        const blob = new Blob([JSON.stringify(tasks, null, 2)], { type: 'application/json' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = 'tasques.json';
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
    }

    const importTasksButton = document.getElementById('import-tasks-button');
    const importTasksInput = document.getElementById('import-tasks-input');

    importTasksButton.addEventListener('click', () => {
        importTasksInput.click();
    });

    importTasksInput.addEventListener('change', (event) => {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();
        reader.onload = function (e) {
            try {
                const tasks = JSON.parse(e.target.result);
                if (!Array.isArray(tasks)) {
                    alert('El archivo no contiene un arreglo de tareas');
                    return;
                }
                localStorage.setItem('tasks', JSON.stringify(tasks));
                taskList.innerHTML = '';
                completedTaskList.innerHTML = '';
                tasks.forEach((task) => {
                    const row = document.createElement('tr');
                    row.innerHTML = `
                <td>${task.date}</td>
                <td>${task.subject}</td>
                <td>${task.description}</td>
                <td><button class="fet ${task.completed ? 'completed' : ''}">${task.completed ? '🔄' : '✅'}</button></td>
                <td><button class="editar">✏️</button></td>
                <td><button class="eliminar">❌</button></td>
              `;
                    if (task.completed) {
                        completedTaskList.appendChild(row);
                    } else {
                        taskList.appendChild(row);
                    }
                });
                alert('Tasques importades correctament');
            } catch (error) {
                alert('Error al importar el fitxer: ' + error.message);
            }
        };
        reader.readAsText(file);
    });

    document.getElementById('export-tasks-button').addEventListener('click', exportTasks);
    document.getElementById('import-tasks-button').addEventListener('click', () => {
        document.getElementById('import-tasks-input').click();
    });


});

