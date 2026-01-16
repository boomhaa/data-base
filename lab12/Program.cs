using System.Configuration;

namespace lab12;

public class Program
{
    static void Main(string[] args)
    {
        try
        {
            var connectionString =
                ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString;

            Console.WriteLine("-- Benchmark started --");

            Console.WriteLine("\n== Connected layer ==");
            ConnectedLayer.Benchmark(connectionString);

            Console.WriteLine("\n== Disconnected layer ==");
            DisconnectedLayer.Benchmark(connectionString);

            Console.WriteLine("\n-- Benchmark finished --");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
        }
    }
}