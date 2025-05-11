import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Scanner;
import javax.swing.JFileChooser;

public class SpotdlDownloader {
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Welcome to SpotdlDownloader program");

        boolean exit = false;

        while (!exit) {
            System.out.println("---- Select Options ----");
            System.out.println("1. Download music/playlist");
            System.out.println("2. Check dependencies");
            System.out.println("3. Exit");
            System.out.print("Option: ");
            System.out.flush();

            String input = scanner.nextLine();

            switch (input) {
                case "1":
                    Download(scanner);
                    break;
                case "2":
                    checkDependencies(scanner);
                    break;
                case "3":
                    System.out.println("Goodbye!");
                    exit = true;
                    break;
                default:
                    System.out.println("Select a valid option please!");
            }
        }

        scanner.close();
    }

    public static void Download(Scanner scanner) {
        System.out.println("Where do you want to save the downloads?");
        System.out.println("1. Custom folder (simple interface)");
        System.out.println("2. Default folder (~/Descargas/Musica/ID)");
        System.out.print("Option (1/2): ");
        System.out.flush();

        String choice = scanner.nextLine();

        String outputPath;

        if (choice.equals("1")) {
            JFileChooser chooser = new JFileChooser();
            chooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
            int returnValue = chooser.showOpenDialog(null);

            if (returnValue == JFileChooser.APPROVE_OPTION) {
                outputPath = chooser.getSelectedFile().getAbsolutePath();
            } else {
                System.out.println("No folder selected. Cancelling download.");
                return;
            }
        } else {
            System.out.print("Enter playlist URL: ");
            String playlistUrl = scanner.nextLine();

            String playlistId;
            try {
                playlistId = playlistUrl.substring(playlistUrl.lastIndexOf("/") + 1, playlistUrl.indexOf("?"));
            } catch (Exception e) {
                System.out.println("Invalid URL format.");
                return;
            }

            outputPath = getDefaultMusicFolderPath() + File.separator + playlistId;
            File dir = new File(outputPath);
            if (!dir.exists()) {
                System.out.println("Creating default folder: " + outputPath);
                dir.mkdirs();
            }

            runSpotDL(playlistUrl, outputPath);
            return;
        }

        // Si eligió carpeta personalizada, ahora se pide la URL
        System.out.print("Enter playlist URL: ");
        String playlistUrl = scanner.nextLine();

        runSpotDL(playlistUrl, outputPath);
    }

    private static void runSpotDL(String playlistUrl, String outputPath) {
        System.out.println("Downloading to: " + outputPath);
    
        String command = "spotdl \"" + playlistUrl + "\" --output \"" + outputPath + File.separator
                + "{title} - {artist}.mp3\"";
    
        try {
            Process process = Runtime.getRuntime().exec(new String[]{"bash", "-c", command});
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line;
    
            while ((line = reader.readLine()) != null) {
                System.out.println();
                System.out.println(line);
    
                // If a song has been downloaded
                if (line.contains("Downloaded")) {
                    String songName = extractSongName(line);
                    System.out.println("Downloaded: " + songName);
    
                    // Pause after each downloaded song
                    System.out.println("Waiting...");
                    try {
                        Thread.sleep(5000); // 5-second pause
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
    
            process.waitFor();
        } catch (IOException | InterruptedException e) {
            System.err.println("Error executing spotdl: " + e.getMessage());
        }
    
        System.out.println("Music download completed!");
    }
    

    private static void checkDependencies(Scanner scanner) {
        System.out.println("Checking dependencies...");
        try {
            Process process = Runtime.getRuntime().exec("which python3");
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            String line = reader.readLine();
            if (line == null) {
                System.out.println("Python3 is not installed. Do you want to install it? (y/n)");
                String choice = scanner.nextLine();
                if (choice.equalsIgnoreCase("y")) {
                    installPython3();
                }
            } else {
                System.out.println("Python3 is installed at: " + line);
            }

            process = Runtime.getRuntime().exec("which pip3");
            reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            line = reader.readLine();
            if (line == null) {
                System.out.println("pip3 is not installed. Do you want to install it? (y/n)");
                String choice = scanner.nextLine();
                if (choice.equalsIgnoreCase("y")) {
                    installPip3();
                }
            } else {
                System.out.println("pip3 is installed at: " + line);
            }

            process = Runtime.getRuntime().exec("which spotdl");
            reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            line = reader.readLine();
            if (line == null) {
                System.out.println("spotdl is not installed. Do you want to install it? (y/n)");
                String choice = scanner.nextLine();
                if (choice.equalsIgnoreCase("y")) {
                    installSpotdl();
                }
            } else {
                System.out.println("spotdl is installed at: " + line);
            }

        } catch (IOException e) {
            System.err.println("Error checking dependencies: " + e.getMessage());
        }
    }

    private static void installSpotdl() {
        try {
            System.out.println("Installing spotdl...");
            Process process = Runtime.getRuntime().exec("pipx install spotdl");
            process.waitFor();
            System.out.println("spotdl installed successfully!");
        } catch (IOException | InterruptedException e) {
            System.err.println("Error installing spotdl: " + e.getMessage());
        }
    }

    private static void installPython3() {
        try {
            System.out.println("Installing Python3...");
            Process process = Runtime.getRuntime().exec("sudo apt-get install python3");
            process.waitFor();
            System.out.println("Python3 installed successfully!");
        } catch (IOException | InterruptedException e) {
            System.err.println("Error installing Python3: " + e.getMessage());
        }
    }

    private static void installPip3() {
        try {
            System.out.println("Installing pip3...");
            Process process = Runtime.getRuntime().exec("sudo apt-get install python3-pip pipx");
            process.waitFor();
            System.out.println("pip3 installed successfully!");
        } catch (IOException | InterruptedException e) {
            System.err.println("Error installing pip3: " + e.getMessage());
        }
    }
    private static String extractSongName(String line) {
        String[] parts = line.split(" - ");
        if (parts.length > 1) {
            return parts[1].trim();
        }
        return "UnknownSong";
    }
    private static String getDefaultMusicFolderPath() {
        String downloadsPath = System.getenv("XDG_DOWNLOAD_DIR");
        if (downloadsPath == null) {
            downloadsPath = System.getProperty("user.home") + File.separator + "Descargas";
        }
        return downloadsPath + File.separator + "Musica";
    }

    
}
