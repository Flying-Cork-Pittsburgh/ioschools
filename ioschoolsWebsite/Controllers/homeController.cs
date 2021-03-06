using System.Linq;
using System.Web.Mvc;
using ioschoolsWebsite.Models.blog;
using ioschoolsWebsite.Models.calendar;

namespace ioschoolsWebsite.Controllers
{
    public class homeController : baseController
    {
        [HttpGet]
        public ActionResult Index()
        {
            var calendar = new Calendar();
            var entries = calendar.GetFutureEvents(7);
            var viewmodel = new BlogSummaryViewData(baseviewmodel);
            viewmodel.events = entries;

            var news = repository.GetBlogs().Where(x => x.ispublic);
            viewmodel.newspanel.news = news.OrderByDescending(x => x.created).Take(4).ToModel();
            return View(viewmodel);
        }
    }
}
