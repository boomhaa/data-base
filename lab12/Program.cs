using System.Configuration;

namespace lab12;

public class Program
{
    static void Main(string[] args)
    {
        var connectionString = ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;
        Console.WriteLine("-- Access layer --");
        Console.WriteLine("1 - Connected layer");
        Console.WriteLine("2 - Disconnected layer");
        Console.WriteLine("3 - Exit");
        Console.Write("\nYour choice: ");
        var choice = int.TryParse(Console.ReadLine(), out var res) ? res : 3;

        switch (choice)
        {
            case 1:
                ConnectedLayer.Init(connectionString);
                break;
            case 2:
                DisconnectedLayer.Init(connectionString);
                break;
            case 3:
                return;
            default:
                Console.WriteLine("There's only 3 options to choose from.");
                return;
        }
    }
}